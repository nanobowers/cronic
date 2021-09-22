module Cronic
  class RepeaterFortnight < Repeater # :nodoc:

    @current_fortnight_start : Time?

    def initialize(type, width = nil, **kwargs)
      super
      @current_fortnight_start = nil
    end

    def next(pointer)
      super

      if @current_fortnight_start.nil?
        case pointer
        when :past
          sunday_repeater = RepeaterDayName.new(:sunday)
          sunday_repeater.start = (@now + 1.day)
          2.times { sunday_repeater.next(:past) }
          last_sunday_span = sunday_repeater.next(:past)
          @current_fortnight_start = last_sunday_span.begin
        else # when :future
          sunday_repeater = RepeaterDayName.new(:sunday)
          sunday_repeater.start = @now
          next_sunday_span = sunday_repeater.next(:future)
          @current_fortnight_start = next_sunday_span.begin
        end
      else
        direction = pointer == :future ? 1 : -1
        @current_fortnight_start = @current_fortnight_start.as(Time) + Time::Span.new(seconds: direction * Date::FORTNIGHT_SECONDS)
      end

      SecSpan.new(@current_fortnight_start.as(Time), @current_fortnight_start.as(::Time) + Time::Span.new(seconds: Date::FORTNIGHT_SECONDS))
    end

    def this(pointer = :future)
      super

      pointer = :future if pointer == :none

      case pointer
      when :future
        this_fortnight_start = Cronic.construct(@now.year, @now.month, @now.day, @now.hour) + Time::Span.new(seconds: TimeUtil::HOUR_SECONDS)
        sunday_repeater = RepeaterDayName.new(:sunday)
        sunday_repeater.start = @now
        sunday_repeater.this(:future)
        this_sunday_span = sunday_repeater.this(:future)
        this_fortnight_end = this_sunday_span.begin
        SecSpan.new(this_fortnight_start, this_fortnight_end)
      when :past
        this_fortnight_end = Cronic.construct(@now.year, @now.month, @now.day, @now.hour)
        sunday_repeater = RepeaterDayName.new(:sunday)
        sunday_repeater.start = @now
        last_sunday_span = sunday_repeater.next(:past)
        this_fortnight_start = last_sunday_span.begin
        SecSpan.new(this_fortnight_start, this_fortnight_end)
      end
    end

    def offset(span, amount, pointer)
      direction = pointer == :future ? 1 : -1
      span + direction * amount * Date::FORTNIGHT_SECONDS
    end

    def width
      Date::FORTNIGHT_SECONDS
    end

    def to_s
      super + "-fortnight"
    end
  end
end
