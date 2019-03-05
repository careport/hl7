require "hl7/subcomponent"

module HL7
  class Component
    def initialize(text, delimiters = Delimiters.default)
      @text = text
      @delimiters = delimiters
    end

    def to_s(unescape: true)
      delimiters.unescape_if(text, unescape)
    end

    def subcomponents
      @subcomponents ||= text.split(delimiters.subcomponent).map do |sub_text|
        Subcomponent.new(sub_text.freeze, delimiters)
      end
    end

    def dig(subcomp_num = nil)
      if subcomp_num.nil?
        to_s
      else
        subcomponents[subcomp_num - 1]&.to_s
      end
    end

    private

    attr_reader :text, :delimiters
  end
end
