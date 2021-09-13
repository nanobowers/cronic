module Cronic
  class RepeaterHour < Repeater #:nodoc:
    HOUR_SECONDS = 3600 # 60 * 60

    @current_hour_start : ::Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_hour_start = nil
    end

    def next(pointer)
      super

      if @current_hour_start.nil?
        case pointer
        when :past
          @current_hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour - 1)
        else # when :future
          @current_hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour + 1)
        end
      else
        direction = pointer == :future ? 1 : -1
        @current_hour_start = @current_hour_start.as(::Time) + ::Time::Span.new(hours: direction)
      end
      chs = @current_hour_start.as(::Time)
      SecSpan.new(chs, chs + ::Time::Span.new(hours: 1))
    end

    def this(pointer = :future)
      super

      case pointer
      when :future
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute + 1)
        hour_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour + 1)
      when :past
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        hour_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour, @now.minute)
      else # when :none
        hour_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        hour_end = hour_start + ::Time::Span.new(hours: 1) # HOUR_SECONDS
      end

      SecSpan.new(hour_start, hour_end)
    end

    def offset(span, amount, pointer)
      direction = (pointer == :future) ? 1 : -1
      span + ::Time::Span.new(hours: direction * amount) 
    end

    def width
      HOUR_SECONDS
    end

    def to_s
      super + "-hour"
    end
  end
end
