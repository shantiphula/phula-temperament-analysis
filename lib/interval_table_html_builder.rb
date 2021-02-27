class IntervalTableHtmlBuilder
  # @return [Proc]
  attr_accessor :does_append_cent_value_proc

  class Result
    # @return [String]
    attr_accessor :html
  end

  def initialize
    @does_append_cent_value_proc = ->cof_analysis { true }
  end

  # @param [Enumerable<CofAnalyzer::Result>] cof_analysises
  def perform(cof_analysises:)
    header_cells = [
        "音程",
        *cof_analysises.map(&:temperament).map(&:name)
    ]

    body_rows = cof_analysises.map { |cof_anal|
      build_column_vector_for_temperament(cof_anal)
    }.transpose.map { |row_cells|
      # 1列目だけ音程名を残し、あとの列は音程名は除去。
      [
          *row_cells[0],
          *row_cells[1..-1].map { |cell|
            cell[1]
          }
      ]
    }

    Result.new.tap { |result|
      result.html = build_html(header_cells, body_rows)
    }
  end

  private
  def build_column_vector_for_temperament(cof_anal)
    cof_anal.all_interval_types.flat_map { |interval_type|
      [
          [interval_type.name, nil],
          *interval_type.interval_dissons.map { |intds|
            [intds.interval.to_s, emoji_from_cents(intds.cents_from_just, cof_analysis: cof_anal)]
          }
      ]
    }
  end

  def build_html(header_cells, body_rows)
    wrap_with_tds = -> cells, tag_proc do
      cells.each_with_index.map { |c, i|
        tag = tag_proc[i]
        "<#{tag}>#{c}</#{tag}>"
      }.join("\n")
    end

    body = body_rows.map { |row_cells|
      <<-EOS.strip
<tr>
#{wrap_with_tds[row_cells, -> i { i == 0 ? "th" : "td" }]}
</tr>
      EOS
    }.join("\n")

    table = <<-EOS
<table class="temper-intervals">
<thead>
<tr>
#{wrap_with_tds[header_cells, -> i { "th" }]}
</tr>
</thead>
<tbody>
#{body}
</tbody>
</table>
    EOS

    <<-EOS
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="assets/interval-table.css">
</head>
<body>

#{table}

</body>
</html>
    EOS
  end

  SYNTONIC_COMMA_BOUNDARIES =
      [0.25, 0.5, 1.0, 1.5, 2.0, 2.5].map { |i| (i * 21.506).round
      }
  # [0.0, 0.25, 0.5, 1.0, 2.0, 3.0].each_cons(2).map { |a,b| ((a+b)/2 * 21.5).round  }

  CENTS_TO_EMOJI_MAP = {
      0 => "&#x2B50;",
      SYNTONIC_COMMA_BOUNDARIES[0] => "&#x1F603;",
      SYNTONIC_COMMA_BOUNDARIES[1] => "&#x1F636;",
      SYNTONIC_COMMA_BOUNDARIES[2] => "&#x1F628;",
      SYNTONIC_COMMA_BOUNDARIES[3] => "&#x1F922;",
      SYNTONIC_COMMA_BOUNDARIES[4] => "&#x1F43A;",
      999 => "&#x1F43A;"*2,
      # 999 => "&#x1F43A;"*2,
      # 999 => "&#x1F43A;"*3
      # 1 => "&#x2B50;",
      # 5 => "&#x1F603;",
      # 10 => "&#x1F636;",
      # 20 => "&#x1F628;",
      # 30 => "&#x1F922;",
      # 40 => "&#x1F43A;",
      # 50 => "&#x1F43A;"*2,
      # 999 => "&#x1F43A;"*3
  }

  def emoji_from_cents(cents, cof_analysis:)
    code = CENTS_TO_EMOJI_MAP[
        CENTS_TO_EMOJI_MAP.keys.find { |upper|
          cents.abs <= upper
        }
    ]
    sign = (cents > 0) ? "+" : ((cents < 0) ? "-" : "")
    appended_cents_value =
        if @does_append_cent_value_proc[cof_analysis]
          (cents != 0) ? "<sub>#{cents.abs}</sub>" : ""
        else
          ""
        end
    "#{sign} #{code}#{appended_cents_value}"
  end
end