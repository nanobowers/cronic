module Cronic
  enum QuarterNames
    Q1 = 0
    Q2 = 1
    Q3 = 2
    Q4 = 3
  end

  class RepeaterQuarterName < RepeaterQuarter
    def initialize(@quarter : QuarterNames, width = nil, **opts)
      super(@quarter.to_s, width)
    end

    def next(pointer)
      if @current_span.nil?
        @current_span = this(pointer)
      else
        span_begin = @current_span.as(SecSpan).begin
        year_offset = pointer.to_dir.value
        new_year = span_begin.year + year_offset
        time_basis = Cronic.construct(new_year, span_begin.month)
        @current_span = quarter(time_basis)
      end

      @current_span
    end

    def this(pointer = PointerDir::Future)
      current_quarter_index = quarter_index(@now.month)
      target_quarter_index = @quarter.value

      year_basis_offset = case pointer
                          in PointerDir::Past   then current_quarter_index > target_quarter_index ? 0 : -1
                          in PointerDir::Future then current_quarter_index < target_quarter_index ? 0 : 1
                          in PointerDir::None   then 0
                          end

      year_basis = @now.year + year_basis_offset
      month_basis = (MONTHS_PER_QUARTER * target_quarter_index) + 1
      time_basis = Cronic.construct(year_basis, month_basis)

      @current_span = quarter(time_basis)
    end
  end
end
