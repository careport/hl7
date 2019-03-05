require "hl7/component"

module HL7
  class Repetition
    def initialize(text, delimiters = Delimiters.default)
      @text = text
      @delimiters = delimiters
    end

    def to_s(unescape: true)
      delimiters.unescape_if(text, unescape)
    end

    def components
      @components ||= text.split(delimiters.component).map do |comp_text|
        Component.new(comp_text.freeze, delimiters)
      end
    end

    def dig(comp_num = nil, subcomp_num = nil)
      if comp_num.nil?
        to_s
      else
        components[comp_num - 1]&.dig(subcomp_num)
      end
    end

    private

    attr_reader :text, :delimiters
  end
end
