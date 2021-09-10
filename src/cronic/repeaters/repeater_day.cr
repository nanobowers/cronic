module Cronic
  class RepeaterDay < Repeater #:nodoc:
    DAY_SECONDS = 86_400 # (24 * 60 * 60)

    @current_day_start : Time
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_day_start = Time.local(@now.year, @now.month, @now.day)
    end

    def next(pointer)
      super

      direction = (pointer == :future) ? 1 : -1
      @current_day_start += Time::Span.new(days: direction)

      SecSpan.new(@current_day_start, @current_day_start + 1.day)
    end

    def this(pointer = :future)
      super

      case pointer
      when :future
        day_begin = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        day_end = Cronic.construct(@now.year, @now.month, @now.day) + 1.day
      when :past
        day_begin = Cronic.construct(@now.year, @now.month, @now.day)
        day_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
      else # when :none
        day_begin = Cronic.construct(@now.year, @now.month, @now.day)
        day_end = Cronic.construct(@now.year, @now.month, @now.day) + 1.day
      end

      SecSpan.new(day_begin, day_end)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + direction * amount * DAY_SECONDS
    end

    def width
      DAY_SECONDS
    end

    def to_s
      super << "-day"
    end
  end
end
