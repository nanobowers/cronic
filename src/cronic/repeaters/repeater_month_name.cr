module Cronic
  enum MonthNames
    January   =  1
    February  =  2
    March     =  3
    April     =  4
    May       =  5
    June      =  6
    July      =  7
    August    =  8
    September =  9
    October   = 10
    November  = 11
    December  = 12
  end

  class RepeaterMonthName < Repeater

    @current_month : MonthNames
    @current_year : Int32
    
    def initialize(@month : MonthNames, width = nil, **kwargs)
      super(@month.to_s, width)
      @current_month = MonthNames.new(@now.month)
      @current_year = @now.year
      @first = true
    end
    
    def start=(time : Time)
      super
      @current_month = MonthNames.new(time.month)
      @current_year = time.year
      @first = true
    end

    def next(pointer : PointerDir) : SecSpan
      if @first
        # First time through adjust year according to if month is
        # relatively in the past/future.
        case pointer
        in PointerDir::Future, PointerDir::None
          @current_year += 1 if @current_month > @month
        in PointerDir::Past
          @current_year -= 1 if @current_month < @month
        end
        @current_month = @month
        @first = false
      else
        @current_year += pointer.to_dir.value
      end

      # Rely on .construct to adjust year if month overflows
      SecSpan.new(
        Cronic.construct(@current_year, @current_month.value),
        Cronic.construct(@current_year, @current_month.value + 1))

    end

    def current_month_begin
      @current_month_begin.as(Time)
    end

    def this(pointer : PointerDir) : SecSpan
      self.next(pointer)
    end

    def width
      Date::MONTH_SECONDS
    end

    def index
      @month.value
    end

    def to_s
      super + "-monthname-" + @type.to_s
    end
  end
end
