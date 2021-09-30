module Cronic
  # :nodoc:
  class RepeaterFortnight < Repeater
    FORTNIGHT_SPAN = 14.days

    @current_fortnight_start : Time?

    def initialize(type, width = nil, **kwargs)
      super
      @current_fortnight_start = nil
    end

    def next(pointer)
      super

      if @current_fortnight_start.nil?
        sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
        case pointer
        in PointerDir::Past
          sunday_repeater.start = (@now + 1.day)
          2.times { sunday_repeater.next(PointerDir::Past) }
          last_sunday_span = sunday_repeater.next(PointerDir::Past)
          @current_fortnight_start = last_sunday_span.begin
        in PointerDir::Future, PointerDir::None
          sunday_repeater.start = @now
          next_sunday_span = sunday_repeater.next(PointerDir::Future)
          @current_fortnight_start = next_sunday_span.begin
        end
      else
        direction = pointer.to_dir.value
        @current_fortnight_start = @current_fortnight_start.as(Time) + FORTNIGHT_SPAN * direction
      end

      Timespan.new(@current_fortnight_start.as(Time), @current_fortnight_start.as(Time) + FORTNIGHT_SPAN)
    end

    def this(pointer : PointerDir)
      sunday_repeater = RepeaterDayName.new(Time::DayOfWeek::Sunday)
      sunday_repeater.start = @now
      case pointer
      in PointerDir::Past
        last_sunday_span = sunday_repeater.next(PointerDir::Past)
        this_fortnight_start = last_sunday_span.begin
        this_fortnight_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        Timespan.new(this_fortnight_start, this_fortnight_end)
      in PointerDir::Future, PointerDir::None
        sunday_repeater.this(PointerDir::Future)
        this_sunday_span = sunday_repeater.this(PointerDir::Future)
        this_fortnight_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour) + Time::Span.new(seconds: TimeUtil::HOUR_SECONDS)
        this_fortnight_end = this_sunday_span.begin
        Timespan.new(this_fortnight_start, this_fortnight_end)
      end
    end

    def offset(span : Timespan, amount : Int32, pointer : PointerDir)
      direction = pointer.to_dir.value
      span + direction * amount * width
    end

    def width
      Date::FORTNIGHT_SECONDS
    end

    def to_s
      super + "-fortnight"
    end
  end
end
