require "hl7/delimiters_parser"
require "hl7/msh_segment"
require "hl7/format_error"

module HL7
  class Message
    attr_reader :segment_map

    def initialize(text, segment_delimiter: "\r")
      @text = text.dup.freeze
      @delimiters = DelimitersParser.parse(text, segment_delimiter.dup)
      @segment_map = parse_segment_map
    end

    def segments
      segment_map.values.flatten
    end

    def to_s(unescape: false)
      delimiters.unescape_if(text, unescape)
    end

    def dig(seg_name, field_num = nil, comp_num = nil, sub_num = nil, segment_rep: 0, field_rep: 0)
      target_segments = segment_map[seg_name].to_a
      sub_dig = Proc.new do |segment|
        segment.dig(field_num, comp_num, sub_num, field_rep: field_rep)
      end

      if segment_rep == "*"
        target_segments.map(&sub_dig)
      else
        target_segments[segment_rep]&.then(&sub_dig)
      end
    end

    private

    attr_reader :text, :delimiters

    def parse_segment_map
      text.
        split(delimiters.segment).
        map { |line| parse_segment(line.freeze) }.
        group_by(&:name)
    end

    def parse_segment(line)
      if line.length < 3
        raise FormatError, "Line too short to contain HL7 segment: #{line}"
      elsif line.start_with?("MSH")
        MSHSegment.new(line, delimiters)
      else
        Segment.new(line, delimiters)
      end
    end
  end
end
