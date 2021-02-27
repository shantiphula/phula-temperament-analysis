require "rational"

module Temperament
  ALL = []

  module Family
    JUST_INTONATION = []
    TEMPERAMENT = []
  end

  # include すると、
  # イ長調の周波数比配列を ratios_from_base_note から得て、
  # C からの周波数比配列に変換して ratios として返す。
  module TunedBasedA
    def ratios
      ratios_from_a = ratios_from_base_note
      ratios_from_c =
          [
              *ratios_from_a,
              *ratios_from_a.map { |x| x*2 }
          ].rotate(3)[0, 12]
      c_per_a = ratios_from_c[0]

      ratios_from_c.map { |r|
        r / c_per_a
      }
    end

    # @abstract
    def ratios_from_base_note
      raise NotImplementedError, ''
    end

    # 各12音間+1オクターヴ上の、Cではなく基音からのセント距離を求める。
    def cents_of_12_notes_from_base
      ratios_from_base_note.map { |r|
        cent = 1200*Math.log2(r)
        cent.round
      }
    end
  end

  class Base
    def octave
      Rational(2, 1)
    end

    def just_perfect_fifth
      Rational(3, 2)
    end

    def just_major_third
      Rational(5, 4)
    end

    # ピタゴラスコンマ ＝ 12の純正な完全五度と7オクターヴとの差
    def pythag_comma
      (just_perfect_fifth ** 12) / (octave ** 7)
    end

    # シントニックコンマ ＝ 完全5度を4回重ねて得られる長3度と純正長3度の差
    def syntonic_comma
      ((just_perfect_fifth ** 4) / (octave ** 2)) / just_major_third
    end

    # スキスマ ＝ ピタゴラスコンマとシントニックコンマの差
    def schisma
      pythag_comma / syntonic_comma
    end

    # 五度圏で次の純正完全5度上の音を求める。
    def next_just_perfect_fifth(r)
      adjust_octave(r * just_perfect_fifth)
    end

    # 周波数比 r がオクターヴを飛び越えたら戻す。
    def adjust_octave(r)
      if r >= 2
        (r / octave)
      elsif r < 1
        (r * octave)
      else
        r
      end
    end

    def name
      raise NotImplementedError, ''
    end

    def ratios
      raise NotImplementedError, ''
    end

    # 各12音間+1オクターヴ上のCのセント距離を求める。
    def cents_from_c_of_notes
      ratios.map { |r|
        cent = 1200*Math.log2(r)
        cent.round
      }
    end

    # 各12音の主音Cからのセント距離を求める。最初は必ず0。
    def cents_between_notes
      [*ratios, 2].each_cons(2).map { |a, b|
        cent = 1200*Math.log2(b / a)
        cent.round
      }
    end

    def self.inherited(subclass)
      ALL << subclass
    end
  end

  class Equal < Base
    Family::TEMPERAMENT << self

    def name
      "十二平均律"
    end

    def ratios
      (0..11).map { |n|
        2 ** Rational(n, 12)
      }
    end
  end

  class Werkmeister1 < Base
    Family::TEMPERAMENT << self

    def name
      "ヴェルクマイスター I(III)調律法"
    end

    def ratios
      one_forth_pythag_comma = pythag_comma ** Rational(1, 4)

      c = prev = Rational(1)
      g = prev = next_just_perfect_fifth(prev) / one_forth_pythag_comma
      d = prev = next_just_perfect_fifth(prev) / one_forth_pythag_comma
      a = prev = next_just_perfect_fifth(prev) / one_forth_pythag_comma
      e = prev = next_just_perfect_fifth(prev)
      h = prev = next_just_perfect_fifth(prev)
      fis = prev = next_just_perfect_fifth(prev) / one_forth_pythag_comma
      cis = prev = next_just_perfect_fifth(prev)
      gis = prev = next_just_perfect_fifth(prev)
      es = prev = next_just_perfect_fifth(prev)
      b = prev = next_just_perfect_fifth(prev)
      f = prev = next_just_perfect_fifth(prev)

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end
  end

  class Kirnberger3 < Base
    Family::TEMPERAMENT << self

    def name
      "キルンベルガー第3法"
    end

    def ratios
      one_forth_syntonic_comma = (syntonic_comma ** Rational(1, 4))

      c = prev = Rational(1)
      g = prev = next_just_perfect_fifth(prev) / one_forth_syntonic_comma
      d = prev = next_just_perfect_fifth(prev) / one_forth_syntonic_comma
      a = prev = next_just_perfect_fifth(prev) / one_forth_syntonic_comma
      e = prev = next_just_perfect_fifth(prev) / one_forth_syntonic_comma
      h = prev = next_just_perfect_fifth(prev)
      fis = prev = next_just_perfect_fifth(prev)
      cis = prev = next_just_perfect_fifth(prev) / schisma
      gis = prev = next_just_perfect_fifth(prev)
      es = prev = next_just_perfect_fifth(prev)
      b = prev = next_just_perfect_fifth(prev)
      f = prev = next_just_perfect_fifth(prev)

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end
  end

  class MeantoneByAron < Base
    Family::TEMPERAMENT << self

    def name
      "中全音律(Aron)"
    end

    def ratios
      one_forth_syntonic_comma = (syntonic_comma ** Rational(1, 4))
      meantone_fifth = just_perfect_fifth / one_forth_syntonic_comma

      c = Rational(1)

      prev = c
      g = prev = adjust_octave(prev * meantone_fifth)
      d = prev = adjust_octave(prev * meantone_fifth)
      a = prev = adjust_octave(prev * meantone_fifth)
      e = prev = adjust_octave(prev * meantone_fifth)
      h = prev = adjust_octave(prev * meantone_fifth)
      fis = prev = adjust_octave(prev * meantone_fifth)
      cis = prev = adjust_octave(prev * meantone_fifth)
      gis = prev = adjust_octave(prev * meantone_fifth)

      prev = c
      f = prev = adjust_octave(prev / meantone_fifth)
      b = prev = adjust_octave(prev / meantone_fifth)
      es = prev = adjust_octave(prev / meantone_fifth)

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end
  end

  class MarpurgMonochord1 < Base
    Family::JUST_INTONATION << self

    def name
      "純正律 Marpurg monochord #1"
    end

    def ratios
      # 主音から完全5度を、下に取ってFを、上に取ってGを得る。
      c = Rational(1)
      f = c / just_perfect_fifth * octave
      g = c * just_perfect_fifth

      # Gから上へ完全5度を取ってDを得る。
      d = g * just_perfect_fifth / octave

      # C,F,Gから上へ長3度を取ってE,A,Hを得る。
      e = c * just_major_third
      a = f * just_major_third
      h = g * just_major_third

      # 全音階から長3度を取り、半音階的半音を得る。
      cis = a * just_major_third / octave
      es = g / just_major_third
      fis = d * just_major_third
      gis = e * just_major_third
      b = d / just_major_third * octave

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end

  end

  class Malcolm < Base
    Family::JUST_INTONATION << self

    def name
      "純正律 Malcolm"
    end

    def ratios
      c = Rational(1)
      f = adjust_octave(c / just_perfect_fifth)
      g = adjust_octave(c * just_perfect_fifth)
      d = adjust_octave(g * just_perfect_fifth)

      a = adjust_octave(f * just_major_third)
      e = adjust_octave(c * just_major_third)
      h = adjust_octave(g * just_major_third)

      cis = c * 17 / 16
      fis = f * 17 / 16
      b = a * 17 / 16

      es = d * 19 / 18
      gis = g * 19 / 18

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end

  end

  class Kirnberger1 < Base
    Family::JUST_INTONATION << self

    def name
      "純正律 キルンベルガー第1法"
    end

    def ratios
      c = prev = Rational(1)
      g = prev = next_just_perfect_fifth(prev)
      d = prev = next_just_perfect_fifth(prev)
      a = prev = next_just_perfect_fifth(prev) / syntonic_comma
      e = prev = next_just_perfect_fifth(prev)
      h = prev = next_just_perfect_fifth(prev)
      fis = prev = next_just_perfect_fifth(prev)
      cis = prev = next_just_perfect_fifth(prev) / schisma
      gis = prev = next_just_perfect_fifth(prev)
      es = prev = next_just_perfect_fifth(prev)
      b = prev = next_just_perfect_fifth(prev)
      f = prev = next_just_perfect_fifth(prev)

      [c, cis, d, es, e, f, fis, g, gis, a, b, h]
    end
  end
end

begin
  require_relative "temperament/hpi"
rescue LoadError
end
