RSpec.describe HL7::Delimiters do
  describe "::default" do
    it "is a struct containing the default HL7 delimiters" do
      delims = HL7::Delimiters.default

      expect(delims.field).to eq("|")
      expect(delims.component).to eq("^")
      expect(delims.repeat).to eq("~")
      expect(delims.escape).to eq("\\")
      expect(delims.subcomponent).to eq("&")
    end
  end

  describe "#unescape" do
    it "unescapes escaped delimiters in strings" do
      delims = HL7::Delimiters.default
      text = "\\F\\ the \\S\\ quick \\T\\ brown \\R\\ fox \\E\\ jumps..."
      expect(delims.unescape(text)).to eq("| the ^ quick & brown ~ fox \\ jumps...")
    end

    it "works with non-default escape characters" do
      delims = HL7::Delimiters.new(
        segment: "\r",
        field: "%",
        component: "?",
        subcomponent: "&",
        repeat: "~",
        escape: "@"
      )
      text = "let's@F@hope@S@this works@E@"
      expect(delims.unescape(text)).to eq("let's%hope?this works@")
    end

    it "returns the text as-is if there is no escape character" do
      delims = HL7::Delimiters.new(
        segment: "\r",
        field: "|",
        component: "^",
        subcomponent: "&",
        repeat: "~",
        escape: nil
      )
      text = "\\F\\ the \\S\\ quick \\T\\ brown \\R\\ fox \\E\\ jumps..."
      expect(delims.unescape(text)).to eq(text)
    end
  end

  describe "#unescape_if" do
    it "unescapes the given text if the condition holds" do
      delims = HL7::Delimiters.default
      text = "foo\\S\\bar"
      expect(delims.unescape_if(text, true)).to eq("foo^bar")
    end

    it "returns the given text as-is if the condition does not hold" do
      delims = HL7::Delimiters.default
      text = "foo\\S\\bar"
      expect(delims.unescape_if(text, false)).to eq("foo\\S\\bar")
    end
  end
end
