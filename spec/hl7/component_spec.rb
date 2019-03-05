RSpec.describe HL7::Component do
  include_examples "to_s examples"

  describe "#subcomponents" do
    it "is an array of the component's subcomponents" do
      text = "C1Data&subC1Data&subC1Data2"
      comp = HL7::Component.new(text)
      subs = comp.subcomponents

      expect(subs.length).to eq(3)
      expect(subs).to all be_a(HL7::Subcomponent)
    end

    it "is an array containing a single subcomponent if there is no subcomponent delimiter" do
      text = "C1Data&subC1Data&subC1Data2"
      delims = HL7::Delimiters.new(
        segment: "\r",
        field: "|",
        component: "^",
        repeat: "~",
        subcomponent: nil,
        escape: nil
      )
      comp = HL7::Component.new(text, delims)
      subs = comp.subcomponents

      expect(subs.length).to eq(1)
      expect(subs.first.to_s).to eq(text)
    end
  end
end
