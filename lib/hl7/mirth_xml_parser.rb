require "nokogiri"

module HL7
  class MirthXmlParser
    def initialize(xml, segment_delimiter: "\r")
      @doc = Nokogiri::XML(xml)
      @segment_delimiter = segment_delimiter
    end

    def to_hl7
      first_elt, *other_elts = @doc.root.element_children
      msh_segment, delimiters = parse_msh(first_elt)
      other_segments = other_elts.
        map { |segment| parse_segment(segment, delimiters) }

      # The segment delimiter is really a terminator, not a delimiter,
      # which is why we add an empty element to the end before joining.
      [msh_segment, *other_segments, ""].join(delimiters.segment)
    end

    private

    def parse_msh(msh)
      validate_msh(msh)

      msh1, msh2, *msh_rest = msh.element_children
      delimiters = parse_delimiters(msh1, msh2)
      msh_segment = [
        "MSH",
        delimiters.encoding_characters,
        *parse_fields(msh_rest, delimiters)
      ].join(delimiters.field)

      [msh_segment, delimiters]
    end

    def validate_msh(msh)
      raise FormatError, "No MSH segment present" if msh.nil?
      raise FormatError, "Expected first segment to be MSH" unless msh.name == "MSH"
    end

    def validate_delimiters(msh1, msh2)
      raise FormatError, "MSH.1 missing" if msh1.nil?
      raise FormatError, "MSH.2 missing" if msh2.nil?

      if msh1.content.length != 1
        raise FormatError, "MSH.1 must contain a single character"
      end

      unless msh2.content.length.between?(2, 4)
        raise FormatError, "MSH.2 must contain 2-4 characters"
      end
    end

    def parse_delimiters(msh1, msh2)
      validate_delimiters(msh1, msh2)

      field_sep = msh1.content
      others = msh2.content

      Delimiters.new(
        segment: @segment_delimiter,
        field: field_sep,
        component: others[0],
        repeat: others[1],
        escape: others[2],
        subcomponent: others[3]
      )
    end

    def parse_segment(segment, delimiters)
      [
        segment.name,
        *parse_fields(segment.element_children, delimiters)
      ].join(delimiters.field)
    end

    def parse_fields(fields, delimiters)
      # Adjacent field elements may have the same name, in which
      # case they are repetitions of the same field.
      # `group_by` preserves order whenever `each` does.
      fields.
        group_by(&:name).
        values.
        map { |field_reps| parse_field_reps(field_reps, delimiters) }.
        join(delimiters.field)
    end

    def parse_field_reps(field_reps, delimiters)
      field_reps.
        map { |field| parse_field(field, delimiters) }.
        join(delimiters.repeat)
    end

    def parse_field(field, delimiters)
      components = field.element_children

      if components.empty?
        field.content
      else
        components.
          map { |component| parse_component(component, delimiters) }.
          join(delimiters.component)
      end
    end

    def parse_component(component, delimiters)
      subcomponents = component.element_children

      if subcomponents.empty? || delimiters.subcomponent.nil?
        component.content
      else
        subcomponents.
          map(&:content).
          join(delimiters.subcomponent)
      end
    end
  end
end
