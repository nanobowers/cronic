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
      in Direction::Forward then self.next
      in Direction::Backward then self.prev
      end
    end
          
    def self.find_next_season(sym : Symbol, pointer : Int32)
      self.find_next_season(symbol_to_season(sym), pointer)
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
    
    def self.symbol_to_season(sym : Symbol) : Season
      lookup = {:spring => Spring, :summer => Summer, :autumn => Autumn, :winter => Winter}
      lookup[sym]
    end
    
  end
  
  class SeasonSpan
    getter :start
    getter :end
    def initialize(@start : MiniDate, @end : MiniDate)
    end
  end
    
end
