module Cronic
  enum MonthNames
    January = 1
    February = 2
    March = 3
    April = 4
    May = 5
    June = 6
    July = 7
    August = 8
    September = 9
    October = 10
    November = 11
    December = 12
  end
  
  class RepeaterMonthName < Repeater # :nodoc:

    # TODO: remove nilability on current-month-begin
    @current_month_begin : Time?

    def initialize(@month : MonthNames , width = nil, **kwargs)
      super(@month.to_s, width)
      @current_month_begin = nil
    end
    
    
    def next(pointer) : SecSpan
      super

      unless @current_month_begin
        case pointer
        in PointerDir::Future
          if @now.month < index
            @current_month_begin = Cronic.construct(@now.year, index)
          elsif @now.month > index
            @current_month_begin = Cronic.construct(@now.year + 1, index)
          end
        in PointerDir::None
          if @now.month <= index
            @current_month_begin = Cronic.construct(@now.year, index)
          elsif @now.month > index
            @current_month_begin = Cronic.construct(@now.year + 1, index)
          end
        in PointerDir::Past
          if @now.month >= index
            @current_month_begin = Cronic.construct(@now.year, index)
          elsif @now.month < index
            @current_month_begin = Cronic.construct(@now.year - 1, index)
          end
        end

        @current_month_begin || raise RuntimeError.new("Current month should be set by now")
      else
        cmb = @current_month_begin.as(Time)
        case pointer
        in PointerDir::Future, PointerDir::None
          @current_month_begin = Cronic.construct(cmb.year + 1, cmb.month)
        in PointerDir::Past
          @current_month_begin = Cronic.construct(cmb.year - 1, cmb.month)
        end
      end

      cur_month_year = current_month_begin.year
      cur_month_month = current_month_begin.month

      if cur_month_month == 12
        next_month_year = cur_month_year + 1
        next_month_month = 1
      else
        next_month_year = cur_month_year
        next_month_month = cur_month_month + 1
      end

      SecSpan.new(current_month_begin, Cronic.construct(next_month_year, next_month_month))
    end

    def current_month_begin
      @current_month_begin.as(Time)
    end

    def this(pointer = PointerDir::Future) : SecSpan
      super
      case pointer
      in PointerDir::Past
        self.next(pointer)
      in PointerDir::Future, PointerDir::None
        self.next(PointerDir::None)
      end
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
