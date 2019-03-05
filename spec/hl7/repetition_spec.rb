RSpec.describe HL7::Repetition do
  include_examples "to_s examples"

  describe "#components" do
    it "is an array of the field repetition's components" do
      text = "C1Data1^C2Data1^c3Data1^C4Data1"
      rep = HL7::Repetition.new(text)
      components = rep.components

      expect(components.length).to eq(4)
      expect(components).to all be_a(HL7::Component)
    end
  end
end
