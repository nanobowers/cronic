module Cronic
  class RepeaterDayName < Repeater #:nodoc:
    DAY_SECONDS = 86400 # (24 * 60 * 60)

    @current_date : ::Time?

    getter :day
    
    def initialize(@day : Time::DayOfWeek, width = nil, **kwargs)
      super(@day.value, width, **kwargs)
      @current_date = nil
    end

    def next(pointer)
      super

      direction = (pointer == :future) ? 1 : -1

      if @current_date.nil?
        @current_date = ::Time.local(@now.year, @now.month, @now.day) + direction.days

        while @current_date.as(Time).day_of_week != @day
          @current_date = @current_date.as(Time) + direction.days
        end
      else
        # move by a week.. This gets a bit wonky around daylight savings time
        # where adding 7 days sometimes adds only 6 days & 23hrs but switches timezones
        @current_date = @current_date.as(Time) + (direction * 7).days
      end
      cdate = @current_date.as(Time)
      next_date = cdate + 1.day
      
      SecSpan.new(Cronic.construct(cdate.year, cdate.month, cdate.day), Cronic.construct(next_date.year, next_date.month, next_date.day))
    end

    def this(pointer = :future)
      super
      pointer = :future if pointer == :none
      self.next(pointer)
    end

    def width
      DAY_SECONDS
    end

    def to_s
      super + "-dayname-" + @day.to_s
    end

    #KILL
    #    private def symbol_to_day_of_the_week(sym)
    #      lookup = {:sunday => ::Time::DayOfWeek::Sunday,
    #                :monday => ::Time::DayOfWeek::Monday,
    #                :tuesday => ::Time::DayOfWeek::Tuesday,
    #                :wednesday => ::Time::DayOfWeek::Wednesday,
    #                :thursday => ::Time::DayOfWeek::Thursday,
    #                :friday => ::Time::DayOfWeek::Friday,
    #                :saturday => ::Time::DayOfWeek::Saturday}
    #      lookup[sym]
    #    end
    #    private def symbol_to_number(sym) : Int32
    #      lookup = {:sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6}
    #      lookup[sym] || raise RuntimeError.new("Invalid symbol specified")
    #    end
  end
end
