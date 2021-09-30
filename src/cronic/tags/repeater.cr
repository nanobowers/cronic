module Cronic
  class Repeater < Tag
    @width : Int32?

    # Scan an Array of Token objects and apply any necessary Repeater
    # tags to each token.
    def self.scan(tokens : Array(Token), **options) : Void
      tokens.each do |token|
        token.tag scan_for_quarter_names(token, **options)
        token.tag scan_for_season_names(token, **options)
        token.tag scan_for_month_names(token, **options)
        token.tag scan_for_day_names(token, **options)
        token.tag scan_for_day_portions(token, **options)
        token.tag scan_for_times(token, **options)
        token.tag scan_for_units(token, **options)
      end
    end

    # token - The Token object we want to scan.
    def self.scan_for_quarter_names(token : Token, **kwargs) : RepeaterQuarterName?
      scan_for token, RepeaterQuarterName,
        {
          /^q1$/ => QuarterNames::Q1,
          /^q2$/ => QuarterNames::Q2,
          /^q3$/ => QuarterNames::Q3,
          /^q4$/ => QuarterNames::Q4,
        }, **kwargs
    end

    # token - The Token object we want to scan.
    def self.scan_for_season_names(token : Token, **kwargs) : RepeaterSeasonName?
      case token.word
      when /^springs?$/          then RepeaterSeasonName.new(Season::Spring, nil)
      when /^summers?$/          then RepeaterSeasonName.new(Season::Summer, nil)
      when /^(autumn)|(fall)s?$/ then RepeaterSeasonName.new(Season::Autumn, nil)
      when /^winters?$/          then RepeaterSeasonName.new(Season::Winter, nil)
      else
        nil
      end
    end

    # token - The Token object we want to scan.
    def self.scan_for_month_names(token : Token, **kwargs) : RepeaterMonthName?
      scan_for token, RepeaterMonthName,
        {
          /^jan[:\.]?(uary)?$/           => MonthNames::January,
          /^feb[:\.]?(ruary)?$/          => MonthNames::February,
          /^mar[:\.]?(ch)?$/             => MonthNames::March,
          /^apr[:\.]?(il)?$/             => MonthNames::April,
          /^may$/                        => MonthNames::May,
          /^jun[:\.]?e?$/                => MonthNames::June,
          /^jul[:\.]?y?$/                => MonthNames::July,
          /^aug[:\.]?(ust)?$/            => MonthNames::August,
          /^sep[:\.]?(t[:\.]?|tember)?$/ => MonthNames::September,
          /^oct[:\.]?(ober)?$/           => MonthNames::October,
          /^nov[:\.]?(ember)?$/          => MonthNames::November,
          /^dec[:\.]?(ember)?$/          => MonthNames::December,
        }, **kwargs
    end

    # token - The Token object we want to scan.
    def self.scan_for_day_names(token : Token, **kwargs) : RepeaterDayName?
      case token.word
      when /^m[ou]n(day)?$/             then RepeaterDayName.new(Time::DayOfWeek::Monday)
      when /^t(ue|eu|oo|u)s?(day)?$/    then RepeaterDayName.new(Time::DayOfWeek::Tuesday)
      when /^we(d|dnes|nds|nns)(day)?$/ then RepeaterDayName.new(Time::DayOfWeek::Wednesday)
      when /^th(u|ur|urs|ers)(day)?$/   then RepeaterDayName.new(Time::DayOfWeek::Thursday)
      when /^fr[iy](day)?$/             then RepeaterDayName.new(Time::DayOfWeek::Friday)
      when /^sat(t?[ue]rday)?$/         then RepeaterDayName.new(Time::DayOfWeek::Saturday)
      when /^su[nm](day)?$/             then RepeaterDayName.new(Time::DayOfWeek::Sunday)
      else                                   nil
      end
    end

    # token - The Token object we want to scan.
    def self.scan_for_day_portions(token : Token, **kwargs) : RepeaterDayPortion?
      scan_for token, RepeaterDayPortion,
        {
          /^ams?$/           => :am,
          /^pms?$/           => :pm,
          /^a\.m\.?$/        => :am,
          /^p\.m\.?$/        => :pm,
          /^mornings?$/      => :morning,
          /^afternoons?$/    => :afternoon,
          /^evenings?$/      => :evening,
          /^(night|nite)s?$/ => :night,
        }, **kwargs
    end

    # token - The Token object we want to scan.
    def self.scan_for_times(token : Token, **kwargs) : RepeaterTime?
      # hour, min, seconds, and fractions of a second down to nanoseconds
      scan_for token, RepeaterTime, /^\d{1,2}(:?\d{1,2})?([\.:]?\d{1,2}([\.:]\d{1,9})?)?$/, **kwargs
    end

    # token - The Token object we want to scan.
    def self.scan_for_units(token : Token, **kwargs)
      case token.word
      when /^years?$/               then RepeaterYear.new(:year, nil, **kwargs)
      when /^q$/                    then RepeaterQuarter.new(:quarter, nil, **kwargs)
      when /^seasons?$/             then RepeaterSeason.new(:season, nil, **kwargs)
      when /^months?$/              then RepeaterMonth.new(:month, nil, **kwargs)
      when /^fortnights?$/          then RepeaterFortnight.new(:fortnight, nil, **kwargs)
      when /^weeks?$/               then RepeaterWeek.new(:week, nil, **kwargs)
      when /^weekends?$/            then RepeaterWeekend.new(:weekend, nil, **kwargs)
      when /^(week|business)days?$/ then RepeaterWeekday.new(:weekday, nil, **kwargs)
      when /^days?$/                then RepeaterDay.new(:day, nil, **kwargs)
      when /^h(ou)?rs?$/            then RepeaterHour.new(:hour, nil, **kwargs)
      when /^min(ute)?s?$/          then RepeaterMinute.new(:minute, nil, **kwargs)
      when /^sec(ond)?s?$/          then RepeaterSecond.new(:second, nil, **kwargs)
      else                               nil
      end
    end

    # Compare width property of two Repeaters
    def <=>(other)
      width <=> other.width
    end

    # Returns the width (in seconds or months) of this repeatable.
    def width
      raise RuntimeError.new("Repeater#width must be overridden in subclasses")
    end

    # Returns the next occurance of this repeatable.
    def next(pointer)
      raise RuntimeError.new("Start point must be set before calling #next") unless @now
    end

    def this(pointer)
      raise RuntimeError.new("Start point must be set before calling #this") unless @now
    end

    def to_s
      "repeater"
    end
  end
end
