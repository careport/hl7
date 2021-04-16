RSpec.describe HL7::DatetimeParser do
  describe "#components" do
    it "is HL7::DatetimeComponents parsed from the given string" do
      expect(HL7::DatetimeParser.new("20190326").components).to eq(
        HL7::DatetimeComponents.new(2019, 3, 26)
      )

      expect(HL7::DatetimeParser.new("20190326140953").components).to eq(
        HL7::DatetimeComponents.new(2019, 3, 26, 14, 9, 53)
      )

      expect(HL7::DatetimeParser.new("20190326140953.425").components).to eq(
        HL7::DatetimeComponents.new(2019, 3, 26, 14, 9, 53, 0.425)
      )

      expect(HL7::DatetimeParser.new("20190326140953.425-0500").components).to eq(
        HL7::DatetimeComponents.new(2019, 3, 26, 14, 9, 53, 0.425, offset_seconds: -18000)
      )
    end

    it "raises ArgumentError when the given text cannot be parsed" do
      expect { HL7::DatetimeParser.new("hello").components }.
        to raise_error(ArgumentError)
    end

    it "raises ArgumentError when given an illegal UTC offset" do
      expect { HL7::DatetimeParser.new("20190326140953.425-0070").components }.
        to raise_error(ArgumentError)
    end
  end
end
