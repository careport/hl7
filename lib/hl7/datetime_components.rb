require 'active_support/core_ext/time'

module HL7
  class DatetimeComponents
    attr_reader :year, :month, :day, :hour, :minute, :second, :fraction, :offset_seconds

    def initialize(year, month = nil, day = nil, hour = nil, minute = nil, second = nil, fraction = nil, offset_seconds: nil)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @minute = minute
      @second = second
      @fraction = fraction
      @offset_seconds = offset_seconds
      validate!
    end

    def to_time(zone:)
      full_seconds = second.to_i + fraction.to_f

      if offset_seconds.nil?
        Time.use_zone(zone) do
          Time.zone.local(year, month, day, hour, minute, full_seconds)
        end
      else
        Time.new(year, month, day, hour, minute, full_seconds, offset_seconds).
          in_time_zone(zone)
      end
    end

    def ==(other)
      other.is_a?(DatetimeComponents) &&
        self.to_time(zone: "UTC").eql?(other.to_time(zone: "UTC"))
    end

    private

    def validate!
      # year is not allowed to be nil
      AttrSpec.new(:year, -9999..9999).validate_non_nil!(year)

      # From month down to fraction-of-second, we validate the fields until we come
      # to a nil value. Once we've found a nil, we ensure that all of the rest of
      # the fields are also nil.
      [
        AttrSpec.new(:month, 1..12),
        AttrSpec.new(:day, -> { 1..Time.days_in_month(month, year) }),
        AttrSpec.new(:hour, 0..23),
        AttrSpec.new(:minute, 0..59),
        AttrSpec.new(:second, 0..59),
        AttrSpec.new(:fraction, 0...1, :real?)
      ].reduce(nil) do |first_nil_attr, spec|
        value = public_send(spec.attr)
        spec.validate!(value, first_nil_attr)
      end

      # offset_seconds is allowed to be nil or not
      AttrSpec.new(:offset_seconds, -64800..64800).validate!(offset_seconds, nil)
    end

    class AttrSpec
      attr_reader :attr

      # The range_or_proc is either a Range or a callable that takes
      # zero arguments and returns a Range. This allows Ranges to
      # be lazily instantiated where necessary.
      def initialize(attr, range_or_proc, predicate = :integer?)
        @attr = attr
        @range_or_proc = range_or_proc
        @predicate = predicate
      end

      # This method always returns the first nil attribute that
      # we've encountered, or nil if we haven't encountered one.
      def validate!(value, first_nil_attr)
        if first_nil_attr.nil?
          # We haven't encountered a nil attribute yet, but this might
          # be the first one.
          if value.nil?
            attr
          else
            validate_non_nil!(value)
            nil
          end
        else
          # We've already encountered a nil attribute, so
          # this one is required to be nil.
          ensure_nil!(value, first_nil_attr)
          first_nil_attr
        end
      end

      def validate_non_nil!(value)
        unless value.respond_to?(predicate) && value.public_send(predicate)
          raise ArgumentError, "#{attr} must satisfy #{predicate}; given #{value.inspect}"
        end

        unless range.cover?(value)
          raise ArgumentError, "#{attr} must be within #{range}; given #{value.inspect}"
        end
      end

      private

      attr_reader :range_or_proc, :predicate

      def range
        if range_or_proc.respond_to?(:call)
          range_or_proc.call
        else
          range_or_proc
        end
      end

      def ensure_nil!(value, first_nil_attr)
        unless value.nil?
          raise ArgumentError, "#{attr} must be nil, because #{first_nil_attr} is nil; instead received #{value.inspect}"
        end
      end
    end

    private_constant :AttrSpec
  end
end
