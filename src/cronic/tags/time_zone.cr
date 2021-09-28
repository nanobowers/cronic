module Cronic
  class TimeZone < Tag
    getter :zone

    def initialize(@zone : Time::Location::Zone)
      super(:tz, 0)
    end

    # Scan an Array of Token objects and apply any necessary TimeZone
    # tags to each token.
    def self.scan(tokens : Array(Token), **options) : Void
      tokens.each do |token|
        if mat = token.word.match(/^(?<sign> tzminus|tzplus|\+|\-)? (?<hours> 0[0-9]|1[0-4]) :? (?<minutes> \d{2})/x)
          sign = (mat["sign"]? && (mat["sign"].downcase == "tzminus" || mat["sign"].downcase == "-")) ? -1 : 1
          hrs = mat["hours"].to_i
          mins = mat["minutes"].to_i
          offset = sign * ((hrs * 3600) + (mins * 60))
          token.tag(TimeZone.new(Time::Location::Zone.new(nil, offset, false)))
        elsif mat = token.word.match(/^(?<zone> [PMCE]) (?<daystd> [DS]) T/xi)
          zonename = token.word.upcase
          # Ruby version identified these four North American timezones
          offset = case mat["zone"].upcase
                   when "E" then 3600*-5 # Eastern
                   when "C" then 3600*-6 # Central
                   when "M" then 3600*-7 # Mountain
                   when "P" then 3600*-8 # Pacific
                   else          raise Exception.new("bad zone #{mat["zone"]}")
                   end
          daylight = mat["daystd"].downcase == "d"
          offset += 3600 if daylight
          token.tag(TimeZone.new(Time::Location::Zone.new(zonename, offset, dst: daylight)))
        elsif token.word =~ /utc/i
          token.tag(TimeZone.new(Time::Location::Zone::UTC))
        end
      end
    end

    def to_s
      "timezone"
    end
  end
end
