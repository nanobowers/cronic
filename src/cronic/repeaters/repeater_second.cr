module Cronic
  class RepeaterSecond < Repeater #:nodoc:
    SECOND_SECONDS = 1 # haha, awesome

    @second_start : Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @second_start = nil
    end

    def next(pointer = :future)
      super

      direction = pointer == :future ? 1 : -1
      posnegsecond = Time::Span.new(seconds: (direction * SECOND_SECONDS))
      
      if @second_start.nil?
        @second_start = @now + posnegsecond
      else
        @second_start = @second_start.as(Time) + posnegsecond
      end
      second_start = @second_start.as(Time)
      SecSpan.new(second_start, second_start + Time::Span.new(seconds: SECOND_SECONDS))
    end

    def this(pointer = :future)
      super

      SecSpan.new(@now, @now + 1.second)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + direction * amount * SECOND_SECONDS
    end

    def width
      SECOND_SECONDS
    end

    def to_s
      super << "-second"
    end
  end
end
