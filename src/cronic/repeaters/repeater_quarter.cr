module Cronic
  # :nodoc:
  class RepeaterQuarter < Repeater
    MONTHS_PER_QUARTER = 3

    @current_span : Timespan?

    def next(pointer)
      @current_span ||= quarter(@now)
      offset_quarter_amount = pointer.to_dir.value
      @current_span = offset_quarter(@current_span.as(Timespan).begin, offset_quarter_amount)
    end

    # For some reason we do not use the context (Future/Past/None)
    def this(context : _)
      @current_span = quarter(@now)
    end

    def offset(span, amount, pointer)
      direction = pointer.to_dir.value
      offset_quarter(span.begin, amount * direction)
    end

    def width
      @current_span ? @current_span.as(Timespan).width : Date::QUARTER_SECONDS
    end

    def to_s
      super + "-quarter"
    end

    protected def quarter_index(month)
      (month - 1) // MONTHS_PER_QUARTER
    end

    protected def quarter(time : Time) : Timespan
      year, month = time.year, time.month

      quarter_index = quarter_index(month)
      quarter_month_start = (quarter_index * MONTHS_PER_QUARTER) + 1
      quarter_month_end = quarter_month_start + MONTHS_PER_QUARTER

      Timespan.new(
        Cronic.construct(year, quarter_month_start),
        Cronic.construct(year, quarter_month_end)
      )
    end

    protected def offset_quarter(time : Time, amount) : Timespan
      new_month = time.month - 1
      new_month = new_month + MONTHS_PER_QUARTER * amount
      new_year = time.year + new_month // 12
      new_month = new_month % 12 + 1

      offset_time_basis = Cronic.construct(new_year, new_month)

      quarter(offset_time_basis)
    end
  end
end
