module Cronic
  class MiniDate
    property :month, :day

    def self.from_time(time)
      new(time.month, time.day)
    end

    def initialize(@month : Int32, @day : Int32)
      unless (1..12).includes?(month)
        raise ArgumentError.new("1..12 are valid months")
      end
    end

    def is_between?(md_start : MiniDate, md_end : MiniDate) : Bool
      return false if (@month == md_start.month && @month == md_end.month) &&
                      (@day < md_start.day || @day > md_end.day)
      return true if (@month == md_start.month && @day >= md_start.day) ||
                     (@month == md_end.month && @day <= md_end.day)

      i = (md_start.month % 12) + 1

      until i == md_end.month
        return true if @month == i
        i = (i % 12) + 1
      end

      return false
    end

    def equals?(other) : Bool
      @month == other.month && @day == other.day
    end
  end
end
