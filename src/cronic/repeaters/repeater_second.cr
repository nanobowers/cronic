module Cronic
  class RepeaterSecond < Repeater

    @second_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @second_start = @now
    end
    
    def start=(time)
      super
      @second_start = @now
    end

    def next(pointer = :future)
      super
      direction = pointer == :future ? 1 : -1
      @second_start += direction.seconds
      SecSpan.new(@second_start, @second_start + 1.second)
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
