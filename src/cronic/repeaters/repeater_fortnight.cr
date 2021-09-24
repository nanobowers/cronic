module Cronic
  class RepeaterFortnight < Repeater
    @current_fortnight_start : Time?

    def initialize(type, width = nil, **kwargs)
      super
      @current_fortnight_start = nil
    end

    def next(pointer)
      super

      if @current_fortnight_start.nil?
        case pointer
        in PointerDir::Past
          sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
          sunday_repeater.start = (@now + 1.day)
          2.times { sunday_repeater.next(PointerDir::Past) }
          last_sunday_span = sunday_repeater.next(PointerDir::Past)
          @current_fortnight_start = last_sunday_span.begin
        in PointerDir::Future, PointerDir::None
          sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
          sunday_repeater.start = @now
          next_sunday_span = sunday_repeater.next(PointerDir::Future)
          @current_fortnight_start = next_sunday_span.begin
        end
      else
        direction = pointer == PointerDir::Future ? 1 : -1
        @current_fortnight_start = @current_fortnight_start.as(Time) + Time::Span.new(seconds: direction * Date::FORTNIGHT_SECONDS)
      end

      SecSpan.new(@current_fortnight_start.as(Time), @current_fortnight_start.as(Time) + Time::Span.new(seconds: Date::FORTNIGHT_SECONDS))
    end

    def this(pointer = PointerDir::Future)
      super
      case pointer
      in PointerDir::Past
        this_fortnight_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
        sunday_repeater.start = @now
        last_sunday_span = sunday_repeater.next(PointerDir::Past)
        this_fortnight_start = last_sunday_span.begin
        SecSpan.new(this_fortnight_start, this_fortnight_end)
      in PointerDir::Future, PointerDir::None
        this_fortnight_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour) + Time::Span.new(seconds: TimeUtil::HOUR_SECONDS)
        sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
        sunday_repeater.start = @now
        sunday_repeater.this(PointerDir::Future)
        this_sunday_span = sunday_repeater.this(PointerDir::Future)
        this_fortnight_end = this_sunday_span.begin
        SecSpan.new(this_fortnight_start, this_fortnight_end)
      end
    end

    def offset(span, amount, pointer) : SecSpan
      direction = pointer == PointerDir::Future ? 1 : -1
      span + direction * amount * Date::FORTNIGHT_SECONDS
    end

    def width
      Date::FORTNIGHT_SECONDS
    end

    def to_s
      super + "-fortnight"
    end
  end
end
