module Cronic
  enum Season
    Spring
    Summer
    Autumn
    Winter

    def next : Season
      nextval = self + 1
      Season.valid?(nextval) ? nextval : Season::Spring
    end

    def prev : Season
      prevval = self - 1
      Season.valid?(prevval) ? prevval : Season::Winter
    end

    def adjust(dir : Direction) : Season
      case dir
      in Direction::Forward  then self.next
      in Direction::Backward then self.prev
      end
    end

    # Use a time-object to calculate the Season.
    def self.find_current_season(time : Time) : Season
      mon = time.month
      day = time.day
      if (mon == 3 && day >= 20) || mon == 4 ||
         mon == 5 || mon == (6 && day <= 20)
        Season::Spring
      elsif (mon == 6 && day >= 21) || mon == 7 ||
            mon == 8 || mon == (9 && day <= 22)
        Season::Summer
      elsif (mon == 9 && day >= 23) || mon == 10 ||
            mon == 11 || (mon == 12 && day <= 21)
        Season::Autumn
      elsif (mon == 12 && day >= 22) || mon == 1 ||
            mon == 2 || (mon == 3 && day <= 19)
        Season::Winter
      else
        # Default return in case nothing else matched (??)
        Season::Spring
      end
    end

    def self.find_next_season(season : Season, pointer : Int32)
      next_season_num = (season + 1 * pointer) % 4
      Season.new(next_season_num)
    end

    def self.span_for_next_season(curtime : Time, nextssn : Season, pointer : PointerDir)
      year = curtime.year
      curssn = Season.find_current_season(curtime)

      # adjust year
      case pointer.to_dir
      in Direction::Forward
        year += 1 if nextssn.value < curssn.value # season next year
      in Direction::Backward
        year -= 1 if nextssn.value > curssn.value # season previous year
      end

      sy, sm, sd, ey, em, ed = SEASON_ADJUSTS[nextssn]
      start_year = sy + year
      end_year = ey + year

      Timespan.new(Cronic.construct(start_year, sm, sd), Cronic.construct(end_year, em, ed))
    end
  end

  SEASON_ADJUSTS = {
    Season::Spring => [0, 3, 20, 0, 6, 20],
    Season::Summer => [0, 6, 21, 0, 9, 22],
    Season::Autumn => [0, 9, 23, 0, 12, 21],
    Season::Winter => [0, 12, 22, 1, 3, 19],
  }
end
