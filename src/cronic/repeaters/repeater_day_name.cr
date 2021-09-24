module Cronic
  class RepeaterDayName < Repeater
    @current_date : Time?

    getter :day

    def initialize(@day : Time::DayOfWeek, width = nil, **kwargs)
      super(@day.value, width, **kwargs)
      @current_date = nil
    end

    def next(pointer : PointerDir)
      direction = pointer.to_dir.value

      if @current_date.nil?
        @current_date = Time.local(@now.year, @now.month, @now.day) + direction.days

        while @current_date.as(Time).day_of_week != @day
          @current_date = @current_date.as(Time) + direction.days
        end
      else
        # move by a week.. This gets a bit wonky around daylight savings time
        # where adding 7 days sometimes adds only 6 days & 23hrs but switches timezones
        @current_date = TimeUtil.add_days(@current_date.as(Time), direction*7)
      end
      cdate = @current_date.as(Time)
      ndate = TimeUtil.add_days(cdate, 1)
      SecSpan.new(cdate, ndate)
    end

    def this(pointer : PointerDir)
      self.next(pointer)
    end

    def width
      Date::DAY_SECONDS
    end

    def to_s
      super + "-dayname-" + @day.to_s
    end
  end
end
