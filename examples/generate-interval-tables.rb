require_relative "../lib/cof_analyzer"
require_relative "../lib/interval_table_html_builder"

def write_interval_table_html(outfile:, temper_classes:)
  tempers = temper_classes.map(&:new)

  IntervalTableHtmlBuilder.new.tap { |builer|
    builer.does_append_cent_value_proc = -> cof_anal {
      true
      # 調和純正律のセント値を出力しない場合：
      # (cof_anal.temperament.class != Temperament::Hpi)
    }
  }.perform(
      cof_analysises:
          tempers.map { |temper|
            CofAnalyzer.new.perform(temper: temper)
          }
  ).tap do |result|
    puts "Writing #{outfile}."
    IO.write(outfile, result.html)
  end
end

write_interval_table_html(
    outfile: "interval-table-just.html",
    temper_classes: [
        *((defined? Temperament::Hpi) ? [Temperament::Hpi] : []),
        Temperament::MarpurgMonochord1,
        Temperament::Malcolm,
        Temperament::Kirnberger1,
    ]
)
write_interval_table_html(
    outfile: "interval-table-tempers.html",
    temper_classes: [
        *((defined? Temperament::Hpi) ? [Temperament::Hpi] : []),
        Temperament::MeantoneByAron,
        Temperament::Werkmeister1,
        Temperament::Kirnberger3,
        Temperament::Equal
    ]
)
