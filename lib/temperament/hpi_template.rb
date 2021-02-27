# ---
# このファイルを hpi.rb にリネームして、
# ratios_from_base_note の配列に、東洋医学セミナーテキストのAからG#までの周波数比を埋めてください。
# ---

module Temperament
  class Hpi < Base
    include Temperament::TunedBasedA

    Family::JUST_INTONATION << self

    def name
      "調和純正律"
    end

    def ratios_from_base_note
      [
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
          Rational(1, 1),
      ]
    end
  end

end
