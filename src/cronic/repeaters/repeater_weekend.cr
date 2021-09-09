module Cronic
  class RepeaterWeekend < Repeater #:nodoc:
    #WEEKEND_SECONDS = 172_800 # (2 * 24 * 60 * 60)
    WEEKEND_SPAN = ::Time::Span.new(days: 2)
    @current_week_start : ::Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @current_week_start = nil
    end

    def next(pointer)
      super

      unless @current_week_start
        case pointer
        when :past
          saturday_repeater = RepeaterDayName.new(:saturday)
          saturday_repeater.start = (@now + ::Time::Span.new(days: 1))
          last_saturday_span = saturday_repeater.next(:past)
          @current_week_start = last_saturday_span.begin
        else # when :future
          saturday_repeater = RepeaterDayName.new(:saturday)
          saturday_repeater.start = @now
          next_saturday_span = saturday_repeater.next(:future)
          @current_week_start = next_saturday_span.begin
        end
      else
        direction = pointer == :future ? 1 : -1
        @current_week_start = @current_week_start.as(::Time) + ::Time::Span.new(days: 7 * direction)
      end
      cws = @current_week_start.as(::Time)
      SecSpan.new(cws, cws + WEEKEND_SPAN)
    end

    def this(pointer = :future)
      super

      case pointer
      when :future, :none
        saturday_repeater = RepeaterDayName.new(:saturday)
        saturday_repeater.start = @now
        this_saturday_span = saturday_repeater.this(:future)
        SecSpan.new(this_saturday_span.begin, this_saturday_span.begin + WEEKEND_SPAN)
      when :past
        saturday_repeater = RepeaterDayName.new(:saturday)
        saturday_repeater.start = @now
        last_saturday_span = saturday_repeater.this(:past)
        SecSpan.new(last_saturday_span.begin, last_saturday_span.begin + WEEKEND_SPAN)
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      weekend = RepeaterWeekend.new(:weekend)
      weekend.start = span.begin
      start = weekend.next(pointer).begin + ::Time::Span.new(days: 7 * direction * (amount - 1))
      SecSpan.new(start, start + (span.end - span.begin))
    end

    def width
      WEEKEND_SECONDS
    end

    def to_s
      super << "-weekend"
    end
  end
end
