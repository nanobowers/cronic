module Cronic
  # :nodoc:
  class RepeaterSeason < Repeater
    @next_season_start : Time
    @next_season_end : Time

    def initialize(xtype, width = nil, **kwargs)
      super
      @next_season_start = Cronic.construct(@now.year, @now.month, @now.day)
      @next_season_end = Cronic.construct(@now.year, @now.month, @now.day)
    end

    def start=(time : Time)
      super
      @next_season_start = Cronic.construct(@now.year, @now.month, @now.day)
      @next_season_end = Cronic.construct(@now.year, @now.month, @now.day)
    end

    def next(pointer)
      super
      cur_ssn = Season.find_current_season(@now)
      next_season = cur_ssn.adjust(pointer.to_dir)
      find_next_season_span(pointer, next_season)
    end

    def this(pointer = PointerDir::Future) : SecSpan
      super

      today = Cronic.construct(@now.year, @now.month, @now.day)
      this_ssn = Season.find_current_season(@now)
      season_span = Season.span_for_next_season(today, this_ssn, pointer)
      case pointer # returns
      in PointerDir::Past
        SecSpan.new(season_span.begin, today)
      in PointerDir::Future
        SecSpan.new(today + 1.day, season_span.end)
      in PointerDir::None
        season_span
      end
    end

    def offset(span, amount, pointer : PointerDir) : SecSpan
      SecSpan.new(offset_by(span.begin, amount, pointer),
        offset_by(span.end, amount, pointer))
    end

    def offset_by(time, amount, pointer : PointerDir)
      direction = pointer.to_dir.value
      time + (amount * direction * width).seconds
    end

    def width
      Date::SEASON_SECONDS
    end

    def to_s
      super + "-season"
    end

    private def find_next_season_span(pointer : PointerDir, next_season)
      next_season_span = Season.span_for_next_season(@now, next_season, pointer)
      @next_season_start = next_season_span.begin
      @next_season_end = next_season_span.end
      next_season_span
    end
  end
end
