module HL7
  class Subcomponent
    def initialize(text, delimiters = HL7::Delimiters.default)
      @text = text
      @delimiters = delimiters
    end

    def to_s(unescape: true)
      delimiters.unescape_if(text, unescape)
    end

    private

    attr_reader :text, :delimiters
  end
end
