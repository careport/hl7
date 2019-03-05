require "hl7/delimiters"

module HL7
  class DelimitersParser
    FIELD_DELIM_IDX = 3

    def self.parse(text, segment_delimiter)
      new(text, segment_delimiter).delimiters
    end

    def initialize(text, segment_delimiter)
      @text = text
      @segment_delimiter = segment_delimiter
    end

    # See HL7 v2 specification, section 2.5.4
    def delimiters
      unless @text.start_with?("MSH")
        raise FormatError, "Message must start with 'MSH'"
      end

      if @text.length < 6
        raise FormatError, "Message too short to contain delimiters"
      end

      Delimiters.new(
        segment: @segment_delimiter,
        field: field_delimiter,
        component: @text[FIELD_DELIM_IDX + 1],
        repeat: @text[FIELD_DELIM_IDX + 2],
        escape: get_optional_delim(FIELD_DELIM_IDX + 3),
        subcomponent: get_optional_delim(FIELD_DELIM_IDX + 4)
      )
    end

    private

    def field_delimiter
      @text[FIELD_DELIM_IDX]
    end

    # Search for the next occurrence of `field_delimiter` after its initial
    # occurrence. That marks the end of MSH.2. If we don't find one, just
    # use the end of the text.
    def end_of_delimiters
      @end_of_delimiters ||=
        @text.index(field_delimiter, FIELD_DELIM_IDX + 1) || @text.length
    end

    def get_optional_delim(idx)
      if idx < end_of_delimiters
        @text[idx]
      else
        nil
      end
    end
  end
end
