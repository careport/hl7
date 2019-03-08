require "hl7/repetition"

module HL7
  class Field
    def initialize(text, delimiters = Delimiters.default)
      @text = text
      @delimiters = delimiters
    end

    def to_s(unescape: true)
      delimiters.unescape_if(text, unescape)
    end

    def repetitions
      @repetitions ||= text.split(delimiters.repeat).map do |rep_text|
        Repetition.new(rep_text.freeze, delimiters)
      end
    end

    def dig(comp_num = nil, sub_num = nil, field_rep: 0)
      sub_dig = Proc.new do |repetition|
        repetition.dig(comp_num, sub_num)
      end

      if field_rep == "*"
        repetitions.map(&sub_dig)
      else
        repetitions[field_rep]&.then(&sub_dig)
      end
    end

    private

    attr_reader :text, :delimiters
  end
end
