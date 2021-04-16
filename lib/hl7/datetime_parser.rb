require "hl7/datetime_components"
require "active_support/core_ext/module/delegation"

module HL7
  class UtcOffset
    attr_reader :sign, :hours, :minutes

    def initialize(sign:, hours:, minutes:)
      @sign = sign
      @hours = hours
      @minutes = minutes
      validate!
    end

    def to_seconds
      abs = (hours * 3600) + (minutes * 60)

      if sign == "-"
        -abs
      else
        abs
      end
    end

    private

    def validate!
      validate_sign!
      validate_component!(:hours, hours, (0..23))
      validate_component!(:minutes, minutes, (0..59))
    end

    def validate_sign!
      unless sign == "-" || sign == "+"
        raise ArgumentError, "UTC offset must begin with '+' or '-'"
      end
    end

    def validate_component!(name, value, range)
      unless value.integer?
        raise ArgumentError, "UTC offset #{name} component must be an integer; given #{value.inspect}"
      end

      unless range.cover?(value)
        raise ArgumentError, "UTC offset #{name} component must be in range #{range}; given #{value.inspect}"
      end
    end
  end

  class DatetimeParser
    # The HL7 datetime format is:
    #    YYYY[MM[DD[HH[MM[SS[.S[S[S[S]]]]]]]]][+/-ZZZZ]
    RX = /\A(\d{4})(?:(\d{2})(?:(\d{2})(?:(\d{2})(?:(\d{2})(?:(\d{2})(\.\d{1,4})?)?)?)?)?)?([-+]\d{4})?\Z/.freeze

    def initialize(text)
      @text = text
    end

    def components
      @_components ||= (
        # year cannot be nil
        year, month, day, hour, minute, second, fraction, offset = match
        utc_offset = build_utc_offset(offset)

        DatetimeComponents.new(
          year.to_i,
          month&.to_i,
          day&.to_i,
          hour&.to_i,
          minute&.to_i,
          second&.to_i,
          fraction&.to_f,
          offset_seconds: utc_offset&.to_seconds
        )
      )
    end

    delegate :to_time, to: :components

    private

    attr_reader :text

    def match
      match_data = text.match(RX)

      if match_data.nil?
        raise ArgumentError, "Invalid HL7 datetime: #{text.inspect}"
      end

      # When we convert MatchData to an Array, the zeroth
      # element is the entire matched string. We only want the
      # matched groups, so we drop the zeroth element.
      match_data.to_a.drop(1)
    end

    # argument is a string that looks like:
    #   -0500
    def build_utc_offset(str)
      if str.nil?
        nil
      else
        sign = str[0]
        hours = str[1..2].to_i
        minutes = str[3..4].to_i
        UtcOffset.new(sign: sign, hours: hours, minutes: minutes)
      end
    end
  end
end
