module Cronic
  class RepeaterMinute < Repeater #:nodoc:
    MINUTE_SECONDS = 60

    @current_minute_start : ::Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_minute_start = nil
    end

    def next(pointer = :future)
      super

      if @current_minute_start.nil?
        direction = pointer == :future ? 1 : -1
        @current_minute_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute) + ::Time::Span.new(minutes: direction)
      else
        direction = pointer == :future ? 1 : -1
        @current_minute_start = @current_minute_start.as(::Time) + direction.minutes
      end
      cms = @current_minute_start.as(::Time)
      SecSpan.new(cms, cms + ::Time::Span.new(minutes: 1))
    end

    def this(pointer = :future)
      super

      case pointer
      when :future
        minute_begin = @now
        minute_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)
      when :past
        minute_begin = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)
        minute_end = @now
      else # when :none
        minute_begin = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)
        minute_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)  + 1.minute
      end

      SecSpan.new(minute_begin, minute_end)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + direction * amount * MINUTE_SECONDS
    end

    def width
      MINUTE_SECONDS
    end

    def to_s
      super << "-minute"
    end
  end
end
