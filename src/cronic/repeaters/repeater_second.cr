module Cronic
  # :nodoc:
  class RepeaterSecond < Repeater
    @second_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @second_start = @now
    end

    def start=(time : Time)
      super
      @second_start = @now
    end

    def next(pointer : PointerDir) : Timespan
      super
      direction = pointer == PointerDir::Future ? 1 : -1
      @second_start += direction.seconds
      Timespan.new(@second_start, @second_start + 1.second)
    end

    def this(pointer : PointerDir) : Timespan
      super
      Timespan.new(@now, @now + 1.second)
    end

    def offset(span : Timespan, amount : Int32, pointer : PointerDir)
      direction = pointer.to_dir.value
      span + direction * amount * width
    end

    def width
      1
    end

    def to_s
      super + "-second"
    end
  end
end
