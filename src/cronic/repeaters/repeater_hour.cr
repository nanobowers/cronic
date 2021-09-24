module Cronic
  class RepeaterHour < Repeater
    @current_hour_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @current_hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
    end

    def start=(time : Time)
      super
      @current_hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
    end

    def next(pointer)
      super
      direction = pointer == PointerDir::Future ? 1 : -1
      @current_hour_start = @current_hour_start.as(Time) + direction.hours
      SecSpan.new(@current_hour_start, @current_hour_start + 1.hour)
    end

    def this(pointer = PointerDir::Future)
      super
      case pointer
      in PointerDir::Future
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute + 1)
        hour_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour + 1)
      in PointerDir::Past
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        hour_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)
      in PointerDir::None
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        hour_end = hour_start + 1.hour
      end
      SecSpan.new(hour_start, hour_end)
    end

    def offset(span, amount, pointer)
      direction = (pointer == PointerDir::Future) ? 1 : -1
      span + (direction * amount).hours
    end

    def width
      TimeUtil::HOUR_SECONDS
    end

    def to_s
      super + "-hour"
    end
  end
end
