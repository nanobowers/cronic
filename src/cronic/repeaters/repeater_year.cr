module Cronic
  class RepeaterYear < Repeater
    @current_year_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @current_year_start = Cronic.construct(@now.year)
    end
    
    def start=(time)
      super
      @current_year_start = Cronic.construct(@now.year)
    end

    def next(pointer)
      super
      diff = pointer == :future ? 1 : -1
      @current_year_start += diff.years
      SecSpan.new(@current_year_start, @current_year_start + 1.year)
    end

    def this(pointer = :future)
      super

      case pointer
      when :future
        this_year_start = Cronic.construct(@now.year, @now.month, @now.day + 1)
        this_year_end = Cronic.construct(@now.year + 1, 1, 1)
      when :past
        this_year_start = Cronic.construct(@now.year, 1, 1)
        this_year_end = Cronic.construct(@now.year, @now.month, @now.day)
      else # when :none
        this_year_start = Cronic.construct(@now.year, 1, 1)
        this_year_end = Cronic.construct(@now.year + 1, 1, 1)
      end

      SecSpan.new(this_year_start, this_year_end)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      new_begin = build_offset_time(span.begin, amount, direction)
      new_end = build_offset_time(span.end, amount, direction)
      SecSpan.new(new_begin, new_end)
    end

    def width
      Date::YEAR_SECONDS
    end

    def to_s
      super + "-year"
    end

    private def build_offset_time(time, amount, direction)
      year = time.year + (amount * direction)
      days = Date.days_in_month(year, time.month)
      day = time.day > days ? days : time.day
      Cronic.construct(year, time.month, day, time.hour, time.minute, time.second)
    end
  end
end
