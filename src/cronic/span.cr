module Cronic
  # A Span represents a range of time. Since this class extends
  # Range, you can use #begin and #end to get the beginning and
  # ending times of the span (they will be of class Time)

  #TODO: Error: can't make class 'Span' inherit generic struct 'Range(Int32, Int32)'
  class Span # < Range(I nt32, Int32)
    getter :begin, :end
    
    def initialize(@begin : ::Time, @end : ::Time)
    end
    
    # Returns the width of this span in seconds
    def width
      (self.end - self.begin).to_i
    end

    # Add a number of seconds to this span, returning the
    # resulting Span
    def +(seconds)
      Span.new(self.begin + seconds, self.end + seconds)
    end

    # Subtract a number of seconds to this span, returning the
    # resulting Span
    def -(seconds)
      #self + -seconds
      Span.new(self.begin - seconds, self.end - seconds)
    end

    # Prints this span in a nice fashion
    def to_s
      "(" + self.begin.to_s + ".." + self.end.to_s << ")"
    end

  end
end
