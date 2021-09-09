module Cronic
  enum Season

    Spring
    Summer
    Autumn
    Winter
    

    def self.find_next_season(season : Symbol, pointer : Int32)
      lookup = {:spring => Spring, :summer => Summer, :autumn => Autumn, :winter => Winter}
      self.find_next_season(lookup[season], pointer)
    end
    
    def self.find_next_season(season : Season, pointer : Int32)
      next_season_num = (season + 1 * pointer) % 4
      Season.new(next_season_num)
    end

    def self.season_after(season)
      find_next_season(season, +1)
    end

    def self.season_before(season)
      find_next_season(season, -1)
    end
  end
  
  class SeasonSpan
    getter :start
    getter :end
    def initialize(@start : MiniDate, @end : MiniDate)
    end
  end
    
end
