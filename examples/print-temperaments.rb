require "pp"
require_relative "../lib/temperament"

pp Temperament::ALL.map(&:new).map { |temper|
  {temper.name => {
      "主音からのセント距離" => temper.cents_from_c_of_notes,
      "各音間のセント距離" => temper.cents_between_notes,
      "周波数比" => temper.ratios.map { |r| r.is_a?(Rational) ? r : r.round(3) },
  }}
}