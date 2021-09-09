module Cronic
  class RepeaterDayName < Repeater #:nodoc:
    DAY_SECONDS = 86400 # (24 * 60 * 60)

    @current_date : ::Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_date = nil
    end

    def next(pointer)
      super

      direction = (pointer == :future) ? 1 : -1

      if @current_date.nil?
        @current_date = ::Time.local(@now.year, @now.month, @now.day) + ::Time::Span.new(days: direction)

        day_of_the_week = symbol_to_day_of_the_week(@type)
        
        while @current_date.as(::Time).day_of_week != day_of_the_week
          @current_date = @current_date.as(::Time) + ::Time::Span.new(days: direction)
        end
      else
        @current_date = @current_date.as(::Time) + ::Time::Span.new(days: direction * 7)
      end
      cdate = @current_date.as(::Time)
      next_date = cdate + ::Time::Span.new(days: 1)
      
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
      super << "-dayname-" << @type.to_s
    end

      private def symbol_to_day_of_the_week(sym)
        lookup = {:sunday => ::Time::DayOfWeek::Sunday,
                  :monday => ::Time::DayOfWeek::Monday,
                  :tuesday => ::Time::DayOfWeek::Tuesday,
                  :wednesday => ::Time::DayOfWeek::Wednesday,
                  :thursday => ::Time::DayOfWeek::Thursday,
                  :friday => ::Time::DayOfWeek::Friday,
                  :saturday => ::Time::DayOfWeek::Saturday}
        lookup[sym]
      end
      
    private def symbol_to_number(sym) : Int32
      lookup = {:sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6}
      lookup[sym] || raise RuntimeError.new("Invalid symbol specified")
    end
  end
end
