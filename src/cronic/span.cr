module Cronic
  # A `Timespan` is a container for a time-span.
  class Timespan
    getter :begin, :end
    property :precision

    def initialize(@begin : Time, @end : Time)
    end

    # Returns the width of this span in seconds
    def width : Int
      (self.end - self.begin).to_i
    end

    # Returns true if the time is between begin and end, inclusive.
    def includes?(val) : Bool
      (@begin..@end).includes?(val)
    end

    # Add an integer number of seconds to this span, returning
    # a new `Timespan`
    def +(seconds : Int32) : Timespan
      adjust = Time::Span.new(seconds: seconds)
      Timespan.new(self.begin + adjust, self.end + adjust)
    end

    # Add a `Time::Span` to this span, returning
    # a new `Timespan`
    def +(seconds : Time::Span) : Timespan
      Timespan.new(self.begin + seconds, self.end + seconds)
    end

    # Subtract a number of seconds to this span, returning
    # a new Timespan
    def -(seconds) : Timespan
      Timespan.new(self.begin - seconds, self.end - seconds)
    end

    # Prints this span in a nice fashion
    def to_s(io)
      io << "(" + self.begin.to_s + ".." + self.end.to_s + ")"
    end

    # Prints this span in a nice fashion for inspection purposes
    def inspect(io)
      self.to_s(io)
    end

    # Returns a `Time` that is in the middle of this span
    def middle : Time
      half_width = Time::Span.new(seconds: self.width // 2)
      self.begin + half_width
    end
  end
end
