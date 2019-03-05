require "hl7/segment"
require "hl7/field"

module HL7
  class MSHSegment < Segment
    # The MSH segment counts fields a bit differently, since it contains
    # the delimiters.
    def fields
      @fields ||= (
        later_fields = text[4..-1].split(delimiters.field)
        all_fields = [name, delimiters.field] + later_fields

        all_fields.map do |field_text|
          Field.new(field_text.freeze, delimiters)
        end
      )
    end
  end
end
