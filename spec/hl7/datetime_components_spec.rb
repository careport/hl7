RSpec.describe HL7::DatetimeComponents do
  describe "[validation]" do
    it "requires the year to be an integer in [-9999, 9999]" do
      expect { HL7::DatetimeComponents.new(2019.5) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(-10000) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(10000) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019) }.
        not_to raise_error
    end

    it "requires the month to be an integer in [1, 12]" do
      expect { HL7::DatetimeComponents.new(2019, -2) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 20) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2) }.
        not_to raise_error
    end

    it "requires the day-of-month to exist, given the year and month" do
      expect { HL7::DatetimeComponents.new(2019, 2, 12.5) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 0) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 29) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28) }.
        not_to raise_error

      expect { HL7::DatetimeComponents.new(2000, 2, 29) }.
        not_to raise_error
    end

    it "requires the hour to be an integer in [0, 23]" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0.001) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, -1) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 24) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0) }.
        not_to raise_error
    end

    it "requires the minute to be an integer in [0, 59]" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, "hi") }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 12, -1) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 12, 100) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 30) }.
        not_to raise_error
    end

    it "requires the second to be an integer in [0, 59]" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, "blah") }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 12, 50, -30) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 12, 50, 60) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23) }.
        not_to raise_error
    end

    it "requires the fraction to be a real in [0, 1)" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, -1) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, 1) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, 0.45) }.
        not_to raise_error
    end

    it "requires the offset_seconds to be an integer in [-64800, 64800]" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, 0.45, offset_seconds: -100000) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, 0.45, offset_seconds: 100000) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, 0, 50, 23, 0.45, offset_seconds: 18000) }.
        not_to raise_error
    end

    it "requires that if any component is nil, all less-significant components are also nil" do
      expect { HL7::DatetimeComponents.new(2019, 2, 28, nil, 10) }.
        to raise_error(ArgumentError)

      expect { HL7::DatetimeComponents.new(2019, 2, 28, nil, nil) }.
        not_to raise_error
    end
  end

  describe "#to_time" do
    it "is the correct Time instance" do
      expect(
        HL7::DatetimeComponents.
          new(1990, 2, 20, 15, 20, 54, 0.23, offset_seconds: -18000).
          to_time(zone: "UTC")
      ).to eq(Time.utc(1990, 2, 20, 20, 20, 54.23))

      expect(
        HL7::DatetimeComponents.
          new(1990, 2, 20).
          to_time(zone: "UTC")
      ).to eq(Time.utc(1990, 2, 20))
    end
  end

  describe "#precision" do
    it "is the name of the least-significant non-nil component (not counting UTC offset)" do
      expect(HL7::DatetimeComponents.new(1990).precision).to eq(:year)
      expect(HL7::DatetimeComponents.new(1990, 2).precision).to eq(:month)
      expect(HL7::DatetimeComponents.new(1990, 2, 20).precision).to eq(:day)
      expect(HL7::DatetimeComponents.new(1990, 2, 20, 15).precision).to eq(:hour)
      expect(HL7::DatetimeComponents.new(1990, 2, 20, 15, 20).precision).to eq(:minute)
      expect(HL7::DatetimeComponents.new(1990, 2, 20, 15, 20, 54).precision).to eq(:second)
      expect(HL7::DatetimeComponents.new(1990, 2, 20, 15, 20, 54, 0.23).precision).to eq(:fraction)
    end
  end
end
