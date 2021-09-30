module Cronic
  # :nodoc:
  class RepeaterWeekend < Repeater
    WEEKEND_SPAN = 2.days

    @current_week_start : Time?

    def initialize(type, width = nil, **kwargs)
      super
      @current_week_start = nil
    end

    def next(pointer)
      super

      if @current_week_start.nil?
        case pointer
        in PointerDir::Past
          saturday_repeater = RepeaterDayName.new(Time::DayOfWeek::Saturday)
          saturday_repeater.start = (@now + 1.days)
          last_saturday_span = saturday_repeater.next(PointerDir::Past)
          @current_week_start = last_saturday_span.begin
        in PointerDir::Future, PointerDir::None
          saturday_repeater = RepeaterDayName.new(Time::DayOfWeek::Saturday)
          saturday_repeater.start = @now
          next_saturday_span = saturday_repeater.next(PointerDir::Future)
          @current_week_start = next_saturday_span.begin
        end
      else
        direction = pointer == PointerDir::Future ? 1 : -1
        @current_week_start = @current_week_start.as(Time) + Time::Span.new(days: 7 * direction)
      end
      cws = @current_week_start.as(Time)
      SecSpan.new(cws, cws + WEEKEND_SPAN)
    end

    def this(pointer = PointerDir::Future)
      super

      case pointer
      in PointerDir::Future, PointerDir::None
        saturday_repeater = RepeaterDayName.new(Time::DayOfWeek::Saturday)
        saturday_repeater.start = @now
        this_saturday_span = saturday_repeater.this(PointerDir::Future)
        SecSpan.new(this_saturday_span.begin, this_saturday_span.begin + WEEKEND_SPAN)
      in PointerDir::Past
        saturday_repeater = RepeaterDayName.new(Time::DayOfWeek::Saturday)
        saturday_repeater.start = @now
        last_saturday_span = saturday_repeater.this(PointerDir::Past)
        SecSpan.new(last_saturday_span.begin, last_saturday_span.begin + WEEKEND_SPAN)
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == PointerDir::Future ? 1 : -1
      weekend = RepeaterWeekend.new(:weekend)
      weekend.start = span.begin
      start = weekend.next(pointer).begin + Time::Span.new(days: 7 * direction * (amount - 1))
      SecSpan.new(start, start + (span.end - span.begin))
    end

    def width
      Date::WEEKEND_SECONDS
    end

    def to_s
      super + "-weekend"
    end
  end
end
