module Cronic
  class RepeaterSeasonName < RepeaterSeason
    def initialize(@season : Season, width = nil)
      super(@season.to_s, width)
    end

    def next(pointer : PointerDir)
      find_next_season_span(pointer, @season)
    end

    def this(pointer = PointerDir::Future)
      today = Cronic.construct(@now.year, @now.month, @now.day)
      season_span = Season.span_for_next_season(today, @season, pointer)
      curr_ssn = Season.find_current_season(@now)
      case pointer
      in PointerDir::Past
        this_ssn_end = (curr_ssn == @season) ? today : season_span.end
        return SecSpan.new(season_span.begin, this_ssn_end)
      in PointerDir::Future
        this_ssn_start = (curr_ssn == @season) ? (today + 1.day) : season_span.begin
        return SecSpan.new(this_ssn_start, season_span.end)
      in PointerDir::None
        return season_span
      end
    end
    
    def offset(span, amount, pointer : PointerDir) : SecSpan
      SecSpan.new(offset_by(span.begin, amount, pointer),
                  offset_by(span.end, amount, pointer))
    end

    def offset_by(time, amount : Int32, pointer : PointerDir)
      direction = pointer.to_dir.value
      time + (amount * direction).years
    end
  end
end
