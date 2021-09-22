module Cronic
  class RepeaterSecond < Repeater # :nodoc:

    @second_start : Time?

    def initialize(type, width = nil, **kwargs)
      super
      @second_start = nil
    end

    def next(pointer = :future)
      super

      direction = pointer == :future ? 1 : -1
      posnegsecond = direction.seconds

      if @second_start.nil?
        @second_start = @now + posnegsecond
      else
        @second_start = @second_start.as(Time) + posnegsecond
      end
      second_start = @second_start.as(Time)
      SecSpan.new(second_start, second_start + 1.second)
    end

    def this(pointer = :future)
      super
      SecSpan.new(@now, @now + 1.second)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + direction * amount
    end

    def width
      1
    end

    def to_s
      super + "-second"
    end
  end
end
