module Cronic
  # A SecSpan represents a range of time in seconds.

  class SecSpan
    getter :begin, :end
    property :precision

    def initialize(@begin : Time, @end : Time)
    end

    # Returns the width of this span in seconds
    def width : Int
      (self.end - self.begin).to_i
    end

    # Returns true if
    def includes?(val) : Bool
      (@begin..@end).includes?(val)
    end

    # Add an integer number of seconds to this span, returning
    # a new SecSpan
    def +(seconds : Int32) : SecSpan
      adjust = Time::Span.new(seconds: seconds)
      SecSpan.new(self.begin + adjust, self.end + adjust)
    end

    # Add a Time::Span to this span, returning
    # a new SecSpan
    def +(seconds : Time::Span) : SecSpan
      SecSpan.new(self.begin + seconds, self.end + seconds)
    end

    # Subtract a number of seconds to this span, returning
    # a new SecSpan
    def -(seconds) : SecSpan
      SecSpan.new(self.begin - seconds, self.end - seconds)
    end

    # Prints this span in a nice fashion
    def to_s
      "(" + self.begin.to_s + ".." + self.end.to_s << ")"
    end

    # Retrieve a Time that is in the middle of this span
    def middle : Time
      half_width = Time::Span.new(seconds: self.width // 2)
      self.begin + half_width
    end
  end
end
