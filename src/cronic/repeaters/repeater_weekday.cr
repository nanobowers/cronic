module Cronic
  class RepeaterWeekday < Repeater
    @current_weekday_start : Time

    def initialize(xtype, width = nil, **kwargs)
      super
      @current_weekday_start = Cronic.construct(@now.year, @now.month, @now.day)
    end

    def start=(time : Time)
      super
      @current_weekday_start = Cronic.construct(@now.year, @now.month, @now.day)
    end

    def next(pointer)
      super

      direction = (pointer == PointerDir::Future) ? 1 : -1

      loop do
        @current_weekday_start += Time::Span.new(days: direction)
        break if @current_weekday_start.weekday?
      end

      SecSpan.new(@current_weekday_start, @current_weekday_start + 1.day)
    end

    def this(pointer = PointerDir::Future)
      super
      case pointer
      in PointerDir::Past
        self.next(PointerDir::Past)
      in PointerDir::Future, PointerDir::None
        self.next(PointerDir::Future)
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == PointerDir::Future ? 1 : -1

      num_weekdays_passed = 0
      offset = 0.seconds
      until num_weekdays_passed == amount
        offset += direction.days
        num_weekdays_passed += 1 if (span.begin + offset).weekday?
      end

      span + offset
    end

    def width
      Date::DAY_SECONDS
    end

    def to_s
      super + "-weekday"
    end
  end
end

# Patching Time from stdlib to add some methods
struct Time
  def weekday? : Bool
    !self.weekend?
  end

  def weekend? : Bool
    doweek = self.day_of_week
    doweek.saturday? || doweek.sunday?
  end
end
