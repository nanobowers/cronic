module Cronic
  class RepeaterWeek < Repeater
    @current_week_start : Time?

    def initialize(xtype, width = nil, week_start : Time::DayOfWeek = Time::DayOfWeek::Sunday, **kwargs)
      super(xtype, width, **kwargs)
      @repeater_day_name = week_start
      @current_week_start = nil
    end

    def next(pointer : PointerDir)
      if @current_week_start.is_a? Time
        direction = pointer.to_dir.value
        @current_week_start = @current_week_start.as(Time) + Time::Span.new(days: 7 * direction)
      else
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        case pointer
        in PointerDir::Past
          first_week_day_repeater.start = (@now + 1.day)
          first_week_day_repeater.next(PointerDir::Past)
          last_span = first_week_day_repeater.next(PointerDir::Past)
          @current_week_start = last_span.begin
        in PointerDir::Future, PointerDir::None
          first_week_day_repeater.start = @now
          next_span = first_week_day_repeater.next(PointerDir::Future)
          @current_week_start = next_span.begin
        end
      end
      cws = @current_week_start.as(Time)
      SecSpan.new(cws, cws + 7.days)
    end

    def this(pointer : PointerDir)
      first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
      first_week_day_repeater.start = @now
      case pointer
      in PointerDir::Future
        this_span = first_week_day_repeater.this(PointerDir::Future)
        this_week_start = Time.local(@now.year, @now.month, @now.day, @now.hour) + 1.hours
        this_week_end = this_span.begin
        SecSpan.new(this_week_start, this_week_end)
      in PointerDir::Past
        last_span = first_week_day_repeater.next(PointerDir::Past)
        this_week_start = last_span.begin
        this_week_end = Time.local(@now.year, @now.month, @now.day, @now.hour)
        SecSpan.new(this_week_start, this_week_end)
      in PointerDir::None
        last_span = first_week_day_repeater.next(PointerDir::Past)
        this_week_start = last_span.begin
        SecSpan.new(this_week_start, this_week_start + 7.days)
      end
    end

    def offset(span : SecSpan, amount : Int32, pointer : PointerDir)
      direction = pointer.to_dir.value
      span + direction * amount * width
    end

    def width
      Date::WEEK_SECONDS
    end

    def to_s
      super + "-week"
    end
  end
end
