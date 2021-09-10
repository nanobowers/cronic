module Cronic
  class RepeaterWeek < Repeater #:nodoc:

    WEEK_SECONDS = 604800 # (7 * 24 * 60 * 60)

    @current_week_start : Time?
    
    def initialize(xtype, width = nil, week_start : Symbol = :sunday, **kwargs)
      super(xtype, width, **kwargs)
      @repeater_day_name = week_start # options[:week_start] || :sunday
      @current_week_start = nil
    end

    def next(pointer)
      super

      if @current_week_start.is_a? Time
        direction = (pointer == :future) ? 1 : -1
        @current_week_start = @current_week_start.as(Time) + Time::Span.new(days: 7 * direction)
      else
        case pointer
        when :past
          first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
          first_week_day_repeater.start = (@now + 1.day)
          first_week_day_repeater.next(:past)
          last_span = first_week_day_repeater.next(:past)
          @current_week_start = last_span.begin
        else # when :future
          first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
          first_week_day_repeater.start = @now
          next_span = first_week_day_repeater.next(:future)
          @current_week_start = next_span.begin
        end
      end
      cws = @current_week_start.as(Time)
      SecSpan.new(cws, cws + 7.days)
    end

    def this(pointer = :future)
      super

      case pointer
      when :future
        this_week_start = Time.local(@now.year, @now.month, @now.day, @now.hour) + 1.hours
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        this_span = first_week_day_repeater.this(:future)
        this_week_end = this_span.begin
        SecSpan.new(this_week_start, this_week_end)
      when :past
        this_week_end = Time.local(@now.year, @now.month, @now.day, @now.hour)
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        last_span = first_week_day_repeater.next(:past)
        this_week_start = last_span.begin
        SecSpan.new(this_week_start, this_week_end)
      else # when :none
        first_week_day_repeater = RepeaterDayName.new(@repeater_day_name)
        first_week_day_repeater.start = @now
        last_span = first_week_day_repeater.next(:past)
        this_week_start = last_span.begin
        SecSpan.new(this_week_start, this_week_start + 7.days) 
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + Time::Span.new(days: 7 * direction * amount) # * WEEK_SECONDS
    end

    def width
      WEEK_SECONDS
    end

    def to_s
      super << "-week"
    end
  end
end
