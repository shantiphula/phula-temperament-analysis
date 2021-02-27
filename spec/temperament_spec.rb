require_relative "../lib/temperament"

RSpec.describe Temperament do
  describe '純正律系' do
    describe Temperament::Kirnberger1 do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 90, 204, 294, 386, 498, 590, 702, 792, 884, 996, 1088]
        )
      end
    end

    describe Temperament::MarpurgMonochord1 do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 71, 204, 316, 386, 498, 590, 702, 773, 884, 1018, 1088]
        )
      end
    end

    describe Temperament::Malcolm do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 105, 204, 298, 386, 498, 603, 702, 796, 884, 989, 1088]
        )
      end
    end
  end

  describe 'テンペラメント' do
    describe Temperament::Equal do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100]
        )
      end
    end

    describe Temperament::Werkmeister1 do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 90, 192, 294, 390, 498, 588, 696, 792, 888, 996, 1092]
        )
      end
    end

    describe Temperament::Kirnberger3 do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 90, 193, 294, 386, 498, 590, 697, 792, 890, 996, 1088]
        )
      end
    end

    describe Temperament::MeantoneByAron do
      it do
        expect(subject.cents_from_c_of_notes).to eq(
            [0, 76, 193, 310, 386, 503, 579, 697, 773, 890, 1007, 1083]
        )
      end
    end
  end
end