RSpec.shared_examples "to_s examples" do
  it "returns the text" do
    subject = described_class.new("hello", HL7::Delimiters.default)
    expect(subject.to_s).to eq("hello")
  end

  it "optionally unescapes the text" do
    subject = described_class.new("hel\\F\\lo", HL7::Delimiters.default)
    expect(subject.to_s(unescape: true)).to eq("hel|lo")
    expect(subject.to_s(unescape: false)).to eq("hel\\F\\lo")
  end
end
