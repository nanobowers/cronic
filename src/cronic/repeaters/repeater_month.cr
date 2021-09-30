module Cronic
  # :nodoc:
  class RepeaterMonth < Repeater
    YEAR_MONTHS = 12

    @current_month_start : Time

    def initialize(type, width = nil, **kwargs)
      super
      @current_month_start = Cronic.construct(@now.year, @now.month)
    end

    def start=(time : Time)
      super
      @current_month_start = Cronic.construct(@now.year, @now.month)
    end

    def next(pointer)
      super
      cms = @current_month_start
      @current_month_start = offset_by(Cronic.construct(cms.year, cms.month), 1, pointer)
      cms = @current_month_start
      Timespan.new(cms, Cronic.construct(cms.year, cms.month) + 1.month)
    end

    def this(pointer = PointerDir::Future)
      super

      case pointer
      in PointerDir::Future
        month_start = Cronic.construct(@now.year, @now.month, @now.day + 1)
        month_end = self.offset_by(Cronic.construct(@now.year, @now.month), 1, PointerDir::Future)
      in PointerDir::Past
        month_start = Cronic.construct(@now.year, @now.month)
        month_end = Cronic.construct(@now.year, @now.month, @now.day)
      in PointerDir::None
        month_start = Cronic.construct(@now.year, @now.month)
        month_end = self.offset_by(Cronic.construct(@now.year, @now.month), 1, PointerDir::Future)
      end

      Timespan.new(month_start, month_end)
    end

    def offset(span, amount, pointer) : Timespan
      Timespan.new(offset_by(span.begin, amount, pointer), offset_by(span.end, amount, pointer))
    end

    def offset_by(time, amount, pointer)
      direction = pointer == PointerDir::Future ? 1 : -1

      amount_years = direction * amount // YEAR_MONTHS
      amount_months = direction * amount % YEAR_MONTHS

      new_year = time.year + amount_years
      new_month = time.month + amount_months
      if new_month > YEAR_MONTHS
        new_year += 1
        new_month -= YEAR_MONTHS
      end

      days = Date.days_in_month(new_year, new_month)
      new_day = time.day > days ? days : time.day

      Cronic.construct(new_year, new_month, new_day, time.hour, time.minute, time.second)
    end

    def width
      Date::MONTH_SECONDS
    end

    def to_s
      super + "-month"
    end
  end
end
