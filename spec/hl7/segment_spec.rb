RSpec.describe HL7::Segment do
  def text
    "PID|1|100001^^^1^MRN1|900001||DOE^JOHN^^^^||19601111|M||WH|111 THAT PL^^HERE^WA^98020^USA||(206)555-5309|||M|NON|999999999"
  end

  include_examples "to_s examples"

  describe "#name" do
    it "is the name of the segment" do
      segment = HL7::Segment.new(text)

      expect(segment.name).to eq("PID")
    end
  end

  describe "#fields" do
    it "is an array of the segment's fields" do
      segment = HL7::Segment.new(text)
      fields = segment.fields

      expect(fields.length).to eq(19)
      expect(fields).to all be_a(HL7::Field)
      expect(fields[3].to_s).to eq("900001")
    end
  end
end
