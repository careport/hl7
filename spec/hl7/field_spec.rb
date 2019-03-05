RSpec.describe HL7::Field do
  include_examples "to_s examples"

  describe "#repetitions" do
    it "is an array of the field repetitions" do
      text = "C1Data1^C2Data1^c3Data1^C4Data1~C1Data2^C2Data2^c3Data2^C4Data2"
      field = HL7::Field.new(text)
      reps = field.repetitions

      expect(reps.length).to eq(2)
      expect(reps).to all be_a(HL7::Repetition)
      expect(reps.map(&:to_s)).to eq [
        "C1Data1^C2Data1^c3Data1^C4Data1",
        "C1Data2^C2Data2^c3Data2^C4Data2"
      ]
    end
  end
end
