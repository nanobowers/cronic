module Cronic
  class RepeaterWeek < Repeater
    @current_week_start : Time?

    def initialize(xtype, width = nil, week_start : Time::DayOfWeek = Time::DayOfWeek::Sunday, **kwargs)
      super(xtype, width, **kwargs)
      @repeater_day_name = week_start
      @current_week_start = nil
    end

    def next(pointer)
      super

      if @current_week_start.is_a? Time
        direction = pointer.to_dir.value
        @current_week_start = @current_week_start.as(Time) + Time::Span.new(days: 7 * direction)
      else
        case pointer
        in PointerDir::Past
          first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
          first_week_day_repeater.start = (@now + 1.day)
          first_week_day_repeater.next(PointerDir::Past)
          last_span = first_week_day_repeater.next(PointerDir::Past)
          @current_week_start = last_span.begin
        in PointerDir::Future, PointerDir::None
          first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
          first_week_day_repeater.start = @now
          next_span = first_week_day_repeater.next(PointerDir::Future)
          @current_week_start = next_span.begin
        end
      end
      cws = @current_week_start.as(Time)
      SecSpan.new(cws, cws + 7.days)
    end

    def this(pointer = PointerDir::Future)
      super

      case pointer
      in PointerDir::Future
        this_week_start = Time.local(@now.year, @now.month, @now.day, @now.hour) + 1.hours
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        this_span = first_week_day_repeater.this(PointerDir::Future)
        this_week_end = this_span.begin
        SecSpan.new(this_week_start, this_week_end)
      in PointerDir::Past
        this_week_end = Time.local(@now.year, @now.month, @now.day, @now.hour)
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        last_span = first_week_day_repeater.next(PointerDir::Past)
        this_week_start = last_span.begin
        SecSpan.new(this_week_start, this_week_end)
      in PointerDir::None
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        last_span = first_week_day_repeater.next(PointerDir::Past)
        this_week_start = last_span.begin
        SecSpan.new(this_week_start, this_week_start + 7.days)
      end
    end

    def offset(span, amount, pointer) : SecSpan
      direction = pointer.to_dir.value
      span + Time::Span.new(days: 7 * direction * amount)
    end

    def width
      Date::WEEK_SECONDS
    end

    def to_s
      super + "-week"
    end
  end
end
