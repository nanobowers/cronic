module Cronic
  class Repeater < Tag

    @width : Int32?
    
    # Scan an Array of Token objects and apply any necessary Repeater
    # tags to each token.
    #
    # tokens - An Array of tokens to scan.
    # options - The Hash of options specified in Cronic::parse.
    #
    # Returns an Array of tokens.
    def self.scan(tokens : Array(Token), **options)
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
    #
    # Returns a new Repeater object.
    def self.scan_for_quarter_names(token, **kwargs)
      scan_for token, RepeaterQuarterName,
      {
        /^q1$/ => :q1,
        /^q2$/ => :q2,
        /^q3$/ => :q3,
        /^q4$/ => :q4
      }, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_season_names(token, **kwargs)
      case token.word
      when /^springs?$/ then RepeaterSeasonName.new(:spring, nil, Season::Spring)
      when /^summers?$/ then RepeaterSeasonName.new(:summer, nil, Season::Summer)
      when /^(autumn)|(fall)s?$/ then RepeaterSeasonName.new(:autumn, nil, Season::Autumn)
      when /^winters?$/ then RepeaterSeasonName.new(:winter, nil, Season::Winter)
      else
        nil
      end
      
      #scan_for token, RepeaterSeasonName,
      #{
      #  /^springs?$/ => :spring,
      #  /^summers?$/ => :summer,
      #  /^(autumn)|(fall)s?$/ => :autumn,
      #  /^winters?$/ => :winter
      #}, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_month_names(token, **kwargs)
      scan_for token, RepeaterMonthName,
      {
        /^jan[:\.]?(uary)?$/ => :january,
        /^feb[:\.]?(ruary)?$/ => :february,
        /^mar[:\.]?(ch)?$/ => :march,
        /^apr[:\.]?(il)?$/ => :april,
        /^may$/ => :may,
        /^jun[:\.]?e?$/ => :june,
        /^jul[:\.]?y?$/ => :july,
        /^aug[:\.]?(ust)?$/ => :august,
        /^sep[:\.]?(t[:\.]?|tember)?$/ => :september,
        /^oct[:\.]?(ober)?$/ => :october,
        /^nov[:\.]?(ember)?$/ => :november,
        /^dec[:\.]?(ember)?$/ => :december
      }, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_day_names(token, **kwargs)
      scan_for token, RepeaterDayName,
      {
        /^m[ou]n(day)?$/ => :monday,
        /^t(ue|eu|oo|u)s?(day)?$/ => :tuesday,
        /^we(d|dnes|nds|nns)(day)?$/ => :wednesday,
        /^th(u|ur|urs|ers)(day)?$/ => :thursday,
        /^fr[iy](day)?$/ => :friday,
        /^sat(t?[ue]rday)?$/ => :saturday,
        /^su[nm](day)?$/ => :sunday
      }, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_day_portions(token, **kwargs)
      scan_for token, RepeaterDayPortion,
      {
        /^ams?$/ => :am,
        /^pms?$/ => :pm,
        /^mornings?$/ => :morning,
        /^afternoons?$/ => :afternoon,
        /^evenings?$/ => :evening,
        /^(night|nite)s?$/ => :night
      }, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_times(token, **kwargs)
      scan_for token, RepeaterTime, /^\d{1,2}(:?\d{1,2})?([\.:]?\d{1,2}([\.:]\d{1,6})?)?$/, **kwargs
    end

    # token - The Token object we want to scan.
    #
    # Returns a new Repeater object.
    def self.scan_for_units(token, **kwargs)
      case token.word
      when /^years?$/ then RepeaterYear.new(:year, nil, **kwargs)
      when /^q$/ then RepeaterQuarter.new(:quarter, nil, **kwargs)
      when /^seasons?$/ then RepeaterSeason.new(:season, nil, **kwargs)
      when /^months?$/ then RepeaterMonth.new(:month, nil, **kwargs)
      when /^fortnights?$/ then RepeaterFortnight.new(:fortnight, nil, **kwargs)
      when /^weeks?$/ then RepeaterWeek.new(:week, nil, **kwargs)
      when /^weekends?$/ then RepeaterWeekend.new(:weekend, nil, **kwargs)
      when /^(week|business)days?$/ then RepeaterWeekday.new(:weekday, nil, **kwargs)
      when /^days?$/ then RepeaterDay.new(:day, nil, **kwargs)
      when /^h(ou)?rs?$/ then RepeaterHour.new(:hour, nil, **kwargs)
      when /^min(ute)?s?$/ then RepeaterMinute.new(:minute, nil, **kwargs)
      when /^sec(ond)?s?$/ then RepeaterSecond.new(:second, nil, **kwargs)
      else
        return nil
      end
    end

    def <=>(other)
      width <=> other.width
    end

    # returns the width (in seconds or months) of this repeatable.
    def width
      raise RuntimeError.new("Repeater#width must be overridden in subclasses")
    end

    # returns the next occurance of this repeatable.
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
