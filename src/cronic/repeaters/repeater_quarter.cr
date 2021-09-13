module Cronic
  class RepeaterQuarter < Repeater #:nodoc:
    MONTHS_PER_QUARTER = 3
    QUARTER_SECONDS = 7_776_000 # 3 * 30 * 24 * 60 * 60

    @current_span : SecSpan?
    
    def next(pointer)
      @current_span ||= quarter(@now)
      offset_quarter_amount = pointer == :future ? 1 : -1
      @current_span = offset_quarter(@current_span.as(SecSpan).begin, offset_quarter_amount)
    end

    def this
      @current_span = quarter(@now)
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      offset_quarter(span.begin, amount * direction)
    end

    def width
      @current_span ? @current_span.as(SecSpan).width : QUARTER_SECONDS
    end

    def to_s
      super + "-quarter"
    end


    protected def quarter_index(month)
      (month - 1) // MONTHS_PER_QUARTER
    end

    protected def quarter(time) : SecSpan
      year, month = time.year, time.month

      quarter_index = quarter_index(month)
      quarter_month_start = (quarter_index * MONTHS_PER_QUARTER) + 1
      quarter_month_end = quarter_month_start + MONTHS_PER_QUARTER

      quarter_start = Cronic.construct(year, quarter_month_start)
      quarter_end = Cronic.construct(year, quarter_month_end)

      SecSpan.new(quarter_start, quarter_end)
    end

    protected def offset_quarter(time, amount) : SecSpan
      new_month = time.month - 1
      new_month = new_month + MONTHS_PER_QUARTER * amount
      new_year = time.year + new_month // 12
      new_month = new_month % 12 + 1

      offset_time_basis = Cronic.construct(new_year, new_month)

      quarter(offset_time_basis)
    end
  end
end
