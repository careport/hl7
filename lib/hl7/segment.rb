require "hl7/field"

module HL7
  class Segment
    attr_reader :name

    def initialize(text, delimiters = HL7::Delimiters.default)
      @text = text
      @delimiters = delimiters
      @name = text[0...3].freeze
    end

    def to_s(unescape: false)
      delimiters.unescape_if(text, unescape)
    end

    def fields
      @_fields ||= text.split(delimiters.field).map do |field_text|
        Field.new(field_text.freeze, delimiters)
      end
    end

    def dig(field_num = nil, comp_num = nil, sub_num = nil, field_rep: 0)
      if field_num.nil?
        to_s
      else
        fields[field_num]&.dig(comp_num, sub_num, field_rep: field_rep)
      end
    end

    private

    attr_reader :text, :delimiters
  end
end
