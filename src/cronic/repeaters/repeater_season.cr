module Cronic
  class RepeaterSeason < Repeater #:nodoc:
    SEASON_SECONDS = 7_862_400 # 91 * 24 * 60 * 60
    SEASONS = {
      :spring => SeasonSpan.new(MiniDate.new(3,20), MiniDate.new(6,20)),
      :summer => SeasonSpan.new(MiniDate.new(6,21), MiniDate.new(9,22)),
      :autumn => SeasonSpan.new(MiniDate.new(9,23), MiniDate.new(12,21)),
      :winter => SeasonSpan.new(MiniDate.new(12,22), MiniDate.new(3,19))
    }

    @next_season_start : Time?
    @next_season_end : Time?
    
    def initialize(type, width = nil, **kwargs)
      super
      @next_season_start = nil
      @next_season_end = nil
    end

    def next(pointer)
      super

      direction = pointer == :future ? 1 : -1
      next_season = Season.find_next_season(find_current_season(MiniDate.from_time(@now)), direction)

      find_next_season_span(direction, next_season)
    end

    def this(pointer = :future)
      super

      direction = pointer == :future ? 1 : -1

      today = Cronic.construct(@now.year, @now.month, @now.day)
      this_ssn = find_current_season(MiniDate.from_time(@now))
      case pointer
      when :past
        this_ssn_start = today + direction * num_seconds_til_start(this_ssn, direction)
        this_ssn_end = today
      when :future
        this_ssn_start = today + RepeaterDay::DAY_SECONDS
        this_ssn_end = today + direction * num_seconds_til_end(this_ssn, direction)
      when :none
        this_ssn_start = today + direction * num_seconds_til_start(this_ssn, direction)
        this_ssn_end = today + direction * num_seconds_til_end(this_ssn, direction)
      end

      construct_season(this_ssn_start, this_ssn_end)
    end

    def offset(span, amount, pointer)
      Span.new(offset_by(span.begin, amount, pointer), offset_by(span.end, amount, pointer))
    end

    def offset_by(time, amount, pointer)
      direction = pointer == :future ? 1 : -1
      time + amount * direction * SEASON_SECONDS
    end

    def width
      SEASON_SECONDS
    end

    def to_s
      super << "-season"
    end

    private def find_next_season_span(direction, next_season)
      unless @next_season_start || @next_season_end
        @next_season_start = Cronic.construct(@now.year, @now.month, @now.day)
        @next_season_end = Cronic.construct(@now.year, @now.month, @now.day)
      end

      @next_season_start += direction * num_seconds_til_start(next_season, direction)
      @next_season_end += direction * num_seconds_til_end(next_season, direction)

      construct_season(@next_season_start, @next_season_end)
    end

    private def find_current_season(md)
      [:spring, :summer, :autumn, :winter].find do |season|
        md.is_between?(SEASONS[season].start, SEASONS[season].end)
      end
    end

    private def num_seconds_til(goal, direction)
      start = Cronic.construct(@now.year, @now.month, @now.day)
      seconds = 0

      until MiniDate.from_time(start + direction * seconds).equals?(goal)
        seconds += RepeaterDay::DAY_SECONDS
      end

      seconds
    end

    private def num_seconds_til_start(season_symbol, direction)
      num_seconds_til(SEASONS[season_symbol].start, direction)
    end

    private def num_seconds_til_end(season_symbol, direction)
      num_seconds_til(SEASONS[season_symbol].end, direction)
    end

    private def construct_season(start, finish)
      Span.new(
        Cronic.construct(start.year, start.month, start.day),
        Cronic.construct(finish.year, finish.month, finish.day)
      )
    end
  end
end
