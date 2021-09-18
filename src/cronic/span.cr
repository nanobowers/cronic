module Cronic
  # A SecSpan represents a range of time in seconds.

  #TODO: Error: can't make class 'Span' inherit generic
  # struct 'Range(Int32, Int32)'

  class SecSpan # < Range(Int32, Int32)
    getter :begin, :end
    property :precision

    def initialize(@begin : Time, @end : Time)
    end
    
    # Returns the width of this span in seconds
    def width
      (self.end - self.begin).to_i
    end

    def includes?(val)
      (@begin .. @end).includes?(val)
    end
      
    # Add a number of seconds to this span, returning the
    # resulting Span
    def +(seconds : Int32)
      adjust = Time::Span.new(seconds: seconds)
      SecSpan.new(self.begin + adjust, self.end + adjust)
    end

    def +(seconds : Time::Span)
      SecSpan.new(self.begin + seconds, self.end + seconds)
    end

    # Subtract a number of seconds to this span, returning the
    # resulting Span
    def -(seconds)
      SecSpan.new(self.begin - seconds, self.end - seconds)
    end

    # Prints this span in a nice fashion
    def to_s
      "(" + self.begin.to_s + ".." + self.end.to_s << ")"
    end

    def middle : Time
      half_width = Time::Span.new(seconds: self.width // 2)
      self.begin + half_width
    end
    
  end
end
