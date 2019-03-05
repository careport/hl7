RSpec.describe HL7::DelimitersParser do
  it "parses the delimiters from an HL7 v2 message" do
    result = HL7::DelimitersParser.parse("MSH|^~\\&|SOU", "\r")
    expect(result).to eq(HL7::Delimiters.default)
  end

  it "parses delimiters without a subcomponent separator" do
    result = HL7::DelimitersParser.parse("MSH|^~\\|SOU", "\r")
    expect(result).to eq(
      HL7::Delimiters.new(
        segment: "\r",
        field: "|",
        component: "^",
        repeat: "~",
        escape: "\\",
        subcomponent: nil
      )
    )
  end

  it "parses delimiters without an escape character or subcomponent separator" do
    result = HL7::DelimitersParser.parse("MSH|^~|SOU", "\r")
    expect(result).to eq(
      HL7::Delimiters.new(
        segment: "\r",
        field: "|",
        component: "^",
        repeat: "~",
        escape: nil,
        subcomponent: nil
      )
    )
  end

  it "parses non-default delimiters" do
    result = HL7::DelimitersParser.parse("MSH;abcd;SOU", "\n")
    expect(result).to eq(
      HL7::Delimiters.new(
        segment: "\n",
        field: ";",
        component: "a",
        repeat: "b",
        escape: "c",
        subcomponent: "d"
      )
    )
  end
end
