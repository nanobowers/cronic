module Cronic
  class TimeZone < Tag

    getter :zone
    
    def initialize(@zone : Time::Location::Zone)
      super(:tz, 0)
    end
      
    # Scan an Array of Token objects and apply any necessary TimeZone
    # tags to each token.
    #
    # tokens - An Array of tokens to scan.
    # options - The Hash of options specified in Cronic::parse.
    #
    # Returns an Array of tokens.
    def self.scan(tokens, **options)
      tokens.each do |token|
        if mat = token.word.match(/^(?<sign> tzminus|tzplus|\+|\-)? (?<hours> 0[0-9]|1[0-4]) :? (?<minutes> \d{2})/x)
          sign = (mat["sign"]? && (mat["sign"].downcase == "tzminus" || mat["sign"].downcase == "-")) ? -1 : 1
          hrs = mat["hours"].to_i
          mins = mat["minutes"].to_i
          offset = sign * ((hrs * 3600) + (mins * 60))
          token.tag( TimeZone.new( Time::Location::Zone.new(nil, offset, false)))
        elsif mat = token.word.match(/^(?<zone> [PMCE]) (?<daystd> [DS]) T/xi)
          zonename = token.word.upcase
          # Ruby version identified these North American timezones
          offset = case mat["zone"].upcase
                   when "E" then 3600*-5 # Eastern
                   when "C" then 3600*-6 # Central
                   when "M" then 3600*-7 # Mountain
                   when "P" then 3600*-8 # Pacific
                   else raise Exception.new("bad zone #{mat["zone"]}") ; end
          daylight = mat["daystd"].downcase == "d"
          offset += 3600 if daylight
          token.tag( TimeZone.new( Time::Location::Zone.new(zonename, offset, dst: daylight)))
        elsif token.word =~ /utc/i
          token.tag( TimeZone.new( Time::Location::Zone::UTC))
        end
        #token.tag scan_for_all(token)
      end
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Pointer object.
#    def self.scan_for_all(token)
#      scan_for token, self,
#      {
#        /[PMCE][DS]T|UTC/i => :tz,
#        /(tzminus|tzplus)?\d{2}:?\d{2}/ => :tz
#      }
#    end

    def to_s
      "timezone"
    end
  end
end
