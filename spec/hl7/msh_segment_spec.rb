RSpec.describe HL7::MSHSegment do
  describe "#fields" do
    it "is an array of the MSH segment's fields" do
      text = "MSH|^~\\&|SOURCEEHR|WA|MIRTHDST|WA|201611111111||ADT^A01|MSGID10001|P|2.3|"
      delims = HL7::Delimiters.default
      msh = HL7::MSHSegment.new(text, delims)
      fields = msh.fields

      expect(fields.length).to eq(13)
      expect(fields).to all be_a(HL7::Field)
      expect(fields[1..3].map(&:to_s)).to eq [
        delims.field,
        delims.encoding_characters,
        "SOURCEEHR"
      ]
    end
  end
end
