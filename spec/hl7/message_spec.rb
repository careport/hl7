RSpec.describe HL7::Message do
  def a01
    HL7::Message.new(HL7Examples.a01)
  end

  describe "#initialize" do
    it "(lazily) parses an HL7 message" do
      expect(a01).to be_a(HL7::Message)
    end

    it "optionally uses a non-default segment delimiter" do
      text = HL7Examples.a01.tr("\r", "\n")
      msg = HL7::Message.new(text, segment_delimiter: "\n")
      expect(msg).to be_a(HL7::Message)
    end

    it "rejects obvious nonsense" do
      text = "hocus pocus"
      expect { HL7::Message.new(text) }.to raise_error(HL7::FormatError)
    end
  end

  describe "#to_s" do
    it "returns the original message text" do
      text = HL7Examples.a01
      msg = HL7::Message.new(text)
      expect(msg.to_s).to eq(text)
    end

    it "optionally unescapes the text" do
      text = "MSH|^~\\&|\\S\\"
      msg = HL7::Message.new(text)
      expect(msg.to_s(unescape: true)).to eq("MSH|^~\\&|^")
    end
  end

  describe "#segment_map" do
    it "is a hash from segment name to array of Segments" do
      expect(a01.segment_map).to include(
        "MSH" => [be_a(HL7::MSHSegment)],
        "EVN" => [be_a(HL7::Segment)],
        "PID" => [be_a(HL7::Segment)],
        "NK1" => [be_a(HL7::Segment), be_a(HL7::Segment)],
        "PV1" => [be_a(HL7::Segment)]
      )
    end
  end

  describe "#segments" do
    it "is a flat array of Segments" do
      segments = a01.segments
      expect(segments.length).to eq(6)
      expect(segments).to all be_a(HL7::Segment)
    end
  end

  describe "#dig" do
    context "with segment_rep: '*'" do
      it "returns an empty array of results when there are no matching segments" do
        expect(a01.dig("XXX", segment_rep: "*")).to be_empty
      end

      it "is a non-empty array when there are matching segments" do
        segments = a01.dig("NK1", segment_rep: "*")
        expect(segments).to eq(
          HL7Examples.a01.scan(/NK1\|[^\r]+/)
        )
      end
    end

    context "with segment_rep: <n>" do
      it "is nil when the requested (zero-indexed) repetition does not exist" do
        expect(a01.dig("MSH", segment_rep: 1)).to be_nil
      end

      it "is the requested segment when the (zero-indexed) repetition does exist" do
        expect(a01.dig("MSH", segment_rep: 0)).to start_with("MSH|")
      end
    end

    it "can query field values" do
      expect(a01.dig("PID", 3)).to eq("900001")
    end

    it "can query repeated field values" do
      expect(a01.dig("PID", 3, field_rep: 1)).to eq("555555")
    end

    it "can query all repeated field values at once" do
      expect(a01.dig("PID", 3, field_rep: "*")).to eq(["900001", "555555"])
    end

    it "can query components" do
      expect(a01.dig("PID", 3, 1)).to eq("900001")
      expect(a01.dig("PID", 2, 5)).to eq("MRN1")
    end

    it "can query subcomponents" do
      expect(a01.dig("PID", 5, 1, 1)).to eq("DOE")
      expect(a01.dig("PID", 5, 1, 2)).to eq("DE")
    end
  end
end
