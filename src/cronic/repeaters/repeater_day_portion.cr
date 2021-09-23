module Cronic
  
  class RepeaterDayPortion < Repeater # :nodoc:

    PORTIONS = {
      :am        => 0..(12 * 60 * 60 - 1),
      :pm        => (12 * 60 * 60)..(24 * 60 * 60 - 1),
      :morning   => (6 * 60 * 60)..(12 * 60 * 60),  # 6am-12am,
      :afternoon => (13 * 60 * 60)..(17 * 60 * 60), # 1pm-5pm,
      :evening   => (17 * 60 * 60)..(20 * 60 * 60), # 5pm-8pm,
      :night     => (20 * 60 * 60)..(24 * 60 * 60), # 8pm-12pm
    }

    @range : Range(Int32, Int32)
    @current_span : SecSpan?

    def initialize(type, width = nil, **kwargs)
      super
      @current_span = nil

      if @type.is_a? Int32
        num = @type.as(Int32)
        @range = (num * 60 * 60)..((num + 12) * 60 * 60)
      else
        @range = PORTIONS[type]
        @range || raise RuntimeError.new("Invalid type '#{type}' for RepeaterDayPortion")
      end

      @range || raise RuntimeError.new("Range should have been set by now")
    end

    def next(pointer)  : SecSpan
      super
      range_begin = @range.begin.seconds
      range_end = @range.end.seconds
      unless @current_span
        now_seconds = @now - Cronic.construct(@now.year, @now.month, @now.day)
        if now_seconds < range_begin
          case pointer
          in PointerDir::Past
            range_start = Cronic.construct(@now.year, @now.month, @now.day - 1) + range_begin
          in PointerDir::Future, PointerDir::None
            range_start = Cronic.construct(@now.year, @now.month, @now.day) + range_begin
          end
        elsif now_seconds > range_end
          case pointer
          in PointerDir::Past
            range_start = Cronic.construct(@now.year, @now.month, @now.day) + range_begin
          in PointerDir::Future, PointerDir::None
            range_start = Cronic.construct(@now.year, @now.month, @now.day + 1) + range_begin
          end
        else
          case pointer
          in PointerDir::Past
            range_start = Cronic.construct(@now.year, @now.month, @now.day - 1) + range_begin
          in PointerDir::Future, PointerDir::None
            range_start = Cronic.construct(@now.year, @now.month, @now.day + 1) + range_begin
          end
        end
        offset = (@range.end - @range.begin)
        range_end = construct_date_from_reference_and_offset(range_start, offset)
        @current_span = SecSpan.new(range_start, range_end)
      else
        days_to_shift_window = (pointer == PointerDir::Past) ? -1 : 1
        cspan = @current_span.as(SecSpan)
        new_begin = Cronic.construct(cspan.begin.year, cspan.begin.month, cspan.begin.day + days_to_shift_window, cspan.begin.hour, cspan.begin.minute, cspan.begin.second)
        new_end = Cronic.construct(cspan.end.year, cspan.end.month, cspan.end.day + days_to_shift_window, cspan.end.hour, cspan.end.minute, cspan.end.second)
        @current_span = SecSpan.new(new_begin, new_end)
      end
    end

    def this(context = PointerDir::Future) : SecSpan
      super

      range_start = Cronic.construct(@now.year, @now.month, @now.day) + @range.begin.seconds
      range_end = construct_date_from_reference_and_offset(range_start)
      @current_span = SecSpan.new(range_start, range_end)
    end

    def offset(span, amount, pointer) : SecSpan
      @now = span.begin
      portion_span = self.next(pointer)
      direction = pointer == PointerDir::Future ? 1 : -1
      portion_span + (direction * (amount - 1) * Date::DAY_SECONDS)
    end

    def width
      @range || raise RuntimeError.new("Range has not been set")
      if @current_span.is_a?(SecSpan)
        return @current_span.as(SecSpan).width
      end
      if @type.is_a?(Int32)
        return (12 * 60 * 60)
      else
        @range.end - @range.begin
      end
    end

    def to_s
      super + "-dayportion-" + @type.to_s
    end

    private def construct_date_from_reference_and_offset(reference, offset = nil)
      reftime = reference.as(Time)
      elapsed_seconds_for_range = offset || (@range.end - @range.begin)
      second_hand = ((elapsed_seconds_for_range - (12 * 60))) % 60
      minute_hand = (elapsed_seconds_for_range - second_hand) // (60) % 60
      hour_hand = (elapsed_seconds_for_range - minute_hand - second_hand) // (60 * 60) + reftime.hour % 24
      Cronic.construct(reftime.year, reftime.month, reftime.day, hour_hand, minute_hand, second_hand)
    end
  end
end
