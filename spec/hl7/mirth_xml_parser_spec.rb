RSpec.describe HL7::MirthXmlParser do
  describe "#to_hl7" do
    it "returns the data as an HL7v2 string" do
      parser = HL7::MirthXmlParser.new(pcc_a01_xml)
      hl7 = parser.to_hl7
      expect(hl7).to eq(expected_hl7)
    end

    it "raises FormatError if the message doesn't have an MSH segment" do
      xml = "<HL7Message><FOO></FOO></HL7Message>"
      parser = HL7::MirthXmlParser.new(xml)

      expect { parser.to_hl7 }.to raise_error(HL7::FormatError)
    end

    it "raises FormatError if the message doesn't contain (enough) delimiters" do
      parser = HL7::MirthXmlParser.new(xml_with_illegal_delimiters)

      expect { parser.to_hl7 }.to raise_error(HL7::FormatError)
    end
  end

  def pcc_a01_xml
    File.read("spec/support/fixtures/pcc_a01.xml")
  end

  def expected_hl7
    hl7 = <<~HL7
    MSH|^~\\&|PCC|YCP0005^HL7P00P|CAREPORT|CAREPORT_ADT|20170210113602.997||ADT^A01|143240405|P|2.5
    EVN|A01|201702101300|||cmarcone|201702101300
    PID|1||4745743^^^^FI~WH-994353^^^^HC~WH-99323645^^^^PN~333-44-5555^^^^SS||Smith^John||19371127|M||White,White|2 Bergenfield Dr.^^South Orange^NJ^02387^United States^^^Essex||^PRN^PH^^^^^^^^^(555) 555-5555||English|Married||WH-9923532|333-44-5555
    PV1|1|I|1 SOUTHBYSOUTHWEST^110^1^^^N^23^1|3 - Elective|||3456345734^Ginsburg^Ruth^^^^^^^^^^NPI|||||||1 - Physician Referral||||2||||||||||||||||||Acute care hospital|The Christ Hospital|||||||201702101300|
    AL1|1||To Be Determined
    DG1|1||C17.9^MALIGNANT NEOPLASM OF SMALL INTESTINE, UNSPECIFIED||20181011|A
    DG1|2|I10C|E78.5|Hyperlipidemia, unspecified|20181112|W
    DG1|3|I10C|Z23|Encounter for immunization|20181213|F
    GT1|1|235235|Smith^John||2 Bergenfield Dr.^^South Organge^NJ^02387^United States^^^Essex||||""|IN|SEL^Self
    IN1|1|^Humana^^998877-00^Managed Care|HUM|Humana|PO Box 14601^^Lexington^KY^40512-4601||||||||||MNC||NON^None||||IN|||||||||||IDK|||PPS|ABC1234567890
    ZEV|2000|201702101300|cmarcone
    HL7

    hl7.tr("\n", "\r")
  end

  def xml_with_illegal_delimiters
    <<~XML
      <HL7Message>
        <MSH>
          <MSH.1>X</MSH.1>
          <MSH.2>Y</MSH.2>
        </MSH>
      </HL7Message>
    XML
  end
end
