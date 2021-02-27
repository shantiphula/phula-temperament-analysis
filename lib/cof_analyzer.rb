require_relative "temperament"

class CofAnalyzer
  Interval = Struct.new(:note1, :note2)
  class Interval
    def notes
      [note1, note2]
    end

    def to_s
      "#{note1} - #{note2}"
    end
  end

  IntervalDissonancy = Struct.new(:interval, :cents_from_just)
  class IntervalDissonancy
    def to_s
      diss_desc = (cents_from_just == 0) ? "純正" : "#{cents_from_just} cents"
      "#{interval} = #{diss_desc}"
    end
  end

  Note = Struct.new(:index_from_c)
  class Note
    C = Note.new(0)
    NAMES_FROM_C = %w"C C# D E♭ E F F# G A♭ A B♭ B C C# D D# E F F# G G# A B♭ B"

    def to_s
      NAMES_FROM_C[index_from_c]
    end

    def self.from_name(name)
      index = NAMES_FROM_C.index(name) or raise("Unknown note name: `#{name}`")
      new(index)
    end
  end

  IntervalType = Struct.new(:name, :interval_dissons)
  class IntervalType

  end

  class Result
    # @return [Temperament::Base]
    attr_accessor :temperament

    # @return [IntervalType]
    attr_accessor :perfect_fifth

    # @return [IntervalType]
    attr_accessor :major_third

    # @return [IntervalType]
    attr_accessor :minor_third

    def all_interval_types
      [perfect_fifth, major_third, minor_third]
    end
  end

  COF_NOTES = %w"C G D A E B F# C# A♭ E♭ B♭ F".map { |name|
    Note.from_name(name)
  }

  def perform(temper:)
    @ratios_from_c = temper.ratios

    Result.new.tap do |result|
      result.temperament = temper

      result.perfect_fifth = IntervalType.new(
          "完全五度",
          analyze_intervals(cof_distance: 1, just_ratio: Rational(3, 2))
      )
      result.major_third = IntervalType.new(
          "長三度",
          analyze_intervals(cof_distance: 4, just_ratio: Rational(5, 4))
      )
      result.minor_third = IntervalType.new(
          "短三度",
          analyze_intervals(cof_distance: 3, just_ratio: Rational(6, 5), invert: true)
      )
    end
  end

  private
  def analyze_intervals(cof_distance:, just_ratio:, invert: false)
    cof_notes = (COF_NOTES * 2)[0, 12 + cof_distance]

    intervals =
        cof_notes.each_cons(cof_distance + 1).map { |cof_notes_on_interval|
          notes = [
              cof_notes_on_interval[0],
              cof_notes_on_interval[-1]
          ]

          Interval.new(
              *(invert ? notes.reverse : notes)
          )
        }

    intervals.map { |interval|
      interval_ratio = interval.notes.map { |note|
        @ratios_from_c[note.index_from_c].to_f
      }.then { |ratio1, ratio2|
        lower, upper =
            if ratio1 < ratio2
              [ratio1, ratio2]
            else
              [ratio1, (ratio2 * 2)]
            end
        (upper / lower)
      }

      cents_from_just = (1200 * Math.log2(interval_ratio / just_ratio)).round

      IntervalDissonancy.new(
          interval, cents_from_just
      )
    }
  end
end

