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

  describe "#precision" do
    it "should be correct, based on the provided fields in the input string" do
      expect(HL7::DatetimeParser.new("2019").precision).to eq(:year)
      expect(HL7::DatetimeParser.new("201903").precision).to eq(:month)
      expect(HL7::DatetimeParser.new("20190326").precision).to eq(:day)
      expect(HL7::DatetimeParser.new("2019032612").precision).to eq(:hour)
      expect(HL7::DatetimeParser.new("201903261230").precision).to eq(:minute)
      expect(HL7::DatetimeParser.new("20190326123022").precision).to eq(:second)
      expect(HL7::DatetimeParser.new("20190326123022.07").precision).to eq(:fraction)
    end

    it "should raise ArgumentError when the given text cannot be parsed" do
      expect { HL7::DatetimeParser.new("hello").precision }.
        to raise_error(ArgumentError)
    end
  end
end
