module Cronic
  class RepeaterWeekday < Repeater #:nodoc:
    DAY_SECONDS = 86400 # (24 * 60 * 60)

#    DAYS = {
#      :sunday => 0,
#      :monday => 1,
#      :tuesday => 2,
#      :wednesday => 3,
#      :thursday => 4,
#      :friday => 5,
#      :saturday => 6
#    }

    @current_weekday_start : ::Time
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_weekday_start = Cronic.construct(@now.year, @now.month, @now.day)
    end

    def next(pointer)
      super

      direction = (pointer == :future) ? 1 : -1

      loop do
        @current_weekday_start += ::Time::Span.new(days: direction)
        break if @current_weekday_start.weekday?
      end

      SecSpan.new(@current_weekday_start, @current_weekday_start + ::Time::Span.new(seconds: DAY_SECONDS))
    end

    def this(pointer = :future)
      super
      case pointer
      when :past
        self.next(:past)
      else # when :future, :none
        self.next(:future)
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1

      num_weekdays_passed = 0
      offset = ::Time::Span.new(seconds: 0)
      until num_weekdays_passed == amount
        offset += ::Time::Span.new(seconds: DAY_SECONDS)
        num_weekdays_passed += 1 if (span.begin + offset).weekday?
      end

      span + offset
    end

    def width
      DAY_SECONDS
    end

    def to_s
      super << "-weekday"
    end

#    private def is_weekend?(time)
#      day == symbol_to_number(:saturday) || day == symbol_to_number(:sunday)
#    end
#    private def is_weekday?(time)
#      !is_weekend?(day)
#    end
#
#    private def symbol_to_number(sym)
#      DAYS[sym] || raise RuntimeError.new("Invalid symbol specified")
#    end
  end
end

struct Time
  def weekday? : Bool
    !self.weekend?
  end
  def weekend? : Bool
    doweek = self.day_of_week
    doweek.saturday? || doweek.sunday?
  end
end
    
