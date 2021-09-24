module Cronic
  class RepeaterDay < Repeater
    @current_day_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @current_day_start = Time.local(@now.year, @now.month, @now.day)
    end

    def start=(time : Time)
      super
      @current_day_start = Time.local(time.year, time.month, time.day)
    end

    def next(pointer) : SecSpan
      super

      direction = (pointer == PointerDir::Future) ? 1 : -1
      @current_day_start += Time::Span.new(days: direction)
      SecSpan.new(@current_day_start, @current_day_start + 1.day)
    end

    def this(pointer = PointerDir::Future) : SecSpan
      super

      case pointer
      in PointerDir::Future
        day_begin = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        day_end = Cronic.construct(@now.year, @now.month, @now.day) + 1.day
      in PointerDir::Past
        day_begin = Cronic.construct(@now.year, @now.month, @now.day)
        day_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
      in PointerDir::None
        day_begin = Cronic.construct(@now.year, @now.month, @now.day)
        day_end = Cronic.construct(@now.year, @now.month, @now.day) + 1.day
      end

      SecSpan.new(day_begin, day_end)
    end

    def offset(span : SecSpan, amount : Int32, pointer)
      direction = pointer == PointerDir::Future ? 1 : -1
      span + (direction * amount).days
    end

    def width
      Date::DAY_SECONDS
    end

    def to_s
      super + "-day"
    end
  end
end
