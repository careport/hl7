module HL7
  Delimiters = Struct.new(
    :segment,
    :field,
    :component,
    :repeat,
    :escape,
    :subcomponent,
    keyword_init: true
  ) do

    def self.default
      new(
        segment: "\r",
        field: "|",
        component: "^",
        repeat: "~",
        escape: "\\",
        subcomponent: "&"
      )
    end

    # The value of MSH.2: the delimiters, in order, not
    # including the field separator, which is in MSH.1,
    # or the segment separator, which is not customizable
    # within the message itself.
    def encoding_characters
      [component, repeat, escape, subcomponent].compact.join
    end

    # See HL7 v2 specification, section 2.7.
    #
    # We handle the following escape sequences:
    # - \F\ (field separator)
    # - \S\ (component separator)
    # - \T\ (subcomponent separator)
    # - \R\ (repetition separator)
    # - \E\ (escape character)
    #
    # We do not handle:
    # - \H\ (start highlighting)
    # - \N\ (normal text; end highlighting)
    # - \Xdddd..\ (hex encoded data)
    # - \Zdddd...\ (locally defined escape sequence)
    # - \Cxxyy\ (single-byte character set escape sequence)
    # - \Mxxyyzz\ (multi-byte character set escape sequence)
    def unescape(text)
      if escape.nil?
        text
      else
        text.gsub(unescape_regexp, unescape_replacements)
      end
    end

    # Convenience method to reduce boilerplate.
    def unescape_if(text, condition)
      if condition
        unescape(text)
      else
        text
      end
    end

    def escape_text(text)
      if escape.nil?
        text
      else
        text.gsub(escape_regexp, escape_replacements)
      end
    end

    private

    def unescape_regexp
      @unescape_regexp ||= (
        e = Regexp.quote(escape)
        /#{e}F#{e}|#{e}S#{e}|#{e}T#{e}|#{e}R#{e}|#{e}E#{e}/
      )
    end

    def unescape_replacements
      @unescape_replacements ||= (
        e = escape

        {
          "#{e}F#{e}" => field,
          "#{e}S#{e}" => component,
          "#{e}T#{e}" => subcomponent,
          "#{e}R#{e}" => repeat,
          "#{e}E#{e}" => escape
        }
      )
    end

    def escape_regexp
      @escape_regexp ||= [field, component, subcomponent, repeat, escape].
        compact.
        map(&Regexp.method(:quote)).
        join("|").
        yield_self(&Regexp.method(:new))
    end

    def escape_replacements
      @escape_replacements ||= (
        e = escape

        {
          field => "#{e}F#{e}",
          component => "#{e}S#{e}",
          subcomponent => "#{e}T#{e}",
          repeat => "#{e}R#{e}",
          escape => "#{e}E#{e}"
        }.compact
      )
    end
  end
end
