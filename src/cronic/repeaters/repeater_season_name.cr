module Cronic
  class RepeaterSeasonName < RepeaterSeason # :nodoc:

    def initialize(@season : Season, width = nil)
      super(@season.to_s, width)
    end

    def next(pointer : PointerDir)
      direction = pointer == PointerDir::Future ? Direction::Forward : Direction::Backward
      find_next_season_span(direction, @season)
    end

    def this(pointer = PointerDir::Future)
      direction = pointer == PointerDir::Future ? Direction::Forward : Direction::Backward

      today = Cronic.construct(@now.year, @now.month, @now.day)
      goal_ssn_start = today + (direction.value * num_seconds_til_start(@season, direction)).seconds
      goal_ssn_end = today + (direction.value * num_seconds_til_end(@season, direction)).seconds
      curr_ssn = find_current_season(MiniDate.from_time(@now))
      case pointer
      in PointerDir::Past
        this_ssn_start = goal_ssn_start
        this_ssn_end = (curr_ssn == @season) ? today : goal_ssn_end
      in PointerDir::Future
        this_ssn_start = (curr_ssn == @season) ? (today + 1.day) : goal_ssn_start
        this_ssn_end = goal_ssn_end
      in PointerDir::None
        this_ssn_start = goal_ssn_start
        this_ssn_end = goal_ssn_end
      end

      construct_season(this_ssn_start, this_ssn_end)
    end

    def offset(span, amount, pointer : PointerDir) : SecSpan
      SecSpan.new(offset_by(span.begin, amount, pointer), offset_by(span.end, amount, pointer))
    end

    def offset_by(time, amount : Int32, pointer : PointerDir)
      direction = pointer == PointerDir::Future ? 1 : -1
      time + (amount * direction).years
    end
  end
end
