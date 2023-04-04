require 'active_support'
require 'active_support/core_ext/time'

module HL7
  class DatetimeComponents
    attr_reader :year, :month, :day, :hour, :minute, :second, :fraction, :offset_seconds, :precision

    def initialize(year, month = nil, day = nil, hour = nil, minute = nil, second = nil, fraction = nil, offset_seconds: nil)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @minute = minute
      @second = second
      @fraction = fraction
      @offset_seconds = offset_seconds

      # precision will be set by #validate!
      @precision = nil
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
      ComponentSpec.new(:year, -9999..9999).validate_non_nil!(year)
      @precision = :year

      # From month down to fraction-of-second, we validate the fields until we come
      # to a nil value. Once we've found a nil, we ensure that all of the rest of
      # the fields are also nil.
      [
        ComponentSpec.new(:month, 1..12),
        ComponentSpec.new(:day, -> { 1..Time.days_in_month(month, year) }),
        ComponentSpec.new(:hour, 0..23),
        ComponentSpec.new(:minute, 0..59),
        ComponentSpec.new(:second, 0..59),
        ComponentSpec.new(:fraction, 0...1, :real?)
      ].reduce(nil) do |first_nil_component, spec|
        value = public_send(spec.component_name)
        @precision = spec.component_name unless value.nil?
        spec.validate!(value, first_nil_component)
      end

      # offset_seconds is allowed to be nil or not
      ComponentSpec.new(:offset_seconds, -64800..64800).validate!(offset_seconds, nil)
    end

    class ComponentSpec
      attr_reader :component_name

      # The range_or_proc is either a Range or a callable that takes
      # zero arguments and returns a Range. This allows Ranges to
      # be lazily instantiated where necessary.
      def initialize(component_name, range_or_proc, predicate = :integer?)
        @component_name = component_name
        @range_or_proc = range_or_proc
        @predicate = predicate
      end

      # This method always returns the name of the first nil component
      # that we've encountered, or nil if we haven't encountered one.
      def validate!(value, first_nil_component)
        if first_nil_component.nil?
          # We haven't encountered a nil component yet, but this might
          # be the first one.
          if value.nil?
            component_name
          else
            validate_non_nil!(value)
            nil
          end
        else
          # We've already encountered a nil component, so
          # this one is required to be nil.
          ensure_nil!(value, first_nil_component)
          first_nil_component
        end
      end

      def validate_non_nil!(value)
        unless value.respond_to?(predicate) && value.public_send(predicate)
          raise ArgumentError, "#{component_name} must satisfy #{predicate}; given #{value.inspect}"
        end

        unless range.cover?(value)
          raise ArgumentError, "#{component_name} must be within #{range}; given #{value.inspect}"
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

      def ensure_nil!(value, first_nil_component)
        unless value.nil?
          raise ArgumentError, "#{component_name} must be nil, because #{first_nil_component} is nil; instead received #{value.inspect}"
        end
      end
    end

    private_constant :ComponentSpec
  end
end
