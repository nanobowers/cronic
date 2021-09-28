module Cronic
  class Date
    YEAR_QUARTERS   =  4
    YEAR_MONTHS     = 12
    SEASON_MONTHS   =  3
    QUARTER_MONTHS  =  3
    MONTH_DAYS      = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    MONTH_DAYS_LEAP = [nil, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    FORTNIGHT_DAYS  = 14
    WEEK_DAYS       =  7
    DAY_HOURS       = 24

    YEAR_SECONDS      = 31_536_000 # 365 * 24 * 60 * 60
    SEASON_SECONDS    =  7_862_400 #  91 * 24 * 60 * 60
    QUARTER_SECONDS   =  7_776_000 #  90 * 24 * 60 * 60
    MONTH_SECONDS     =  2_592_000 #  30 * 24 * 60 * 60
    FORTNIGHT_SECONDS =  1_209_600 #  14 * 24 * 60 * 60
    WEEK_SECONDS      =    604_800 #   7 * 24 * 60 * 60
    WEEKEND_SECONDS   =    172_800 #   2 * 24 * 60 * 60
    DAY_SECONDS       =     86_400 #       24 * 60 * 60

    # Checks if given number could be day
    def self.could_be_day?(day, width = nil)
      day >= 1 && day <= 31 && (width.nil? || width <= 2)
    end

    # Checks if given number could be month
    def self.could_be_month?(month, width = nil)
      month >= 1 && month <= 12 && (width.nil? || width <= 2)
    end

    # Checks if given number could be year
    def self.could_be_year?(year, width = nil)
      year >= 0 && year <= 9999 && (width.nil? || width == 2 || width == 4)
    end

    # Build a year from a 2 digit suffix.
    #
    # year - The two digit Integer year to build from.
    # bias - The Integer amount of future years to bias.
    #
    # Examples:
    #
    #   make_year(96, 50) #=> 1996
    #   make_year(79, 20) #=> 2079
    #   make_year(00, 50) #=> 2000
    #
    # Returns The Integer 4 digit year.
    def self.make_year(year : Int32, bias)
      return year if year.to_s.size > 2
      start_year = Time.local.year - bias
      century = (start_year // 100) * 100
      full_year = century + year
      full_year += 100 if full_year < start_year
      full_year
    end

    def self.days_in_month(year : Int32, month : Int32)
      days_month = Time.leap_year?(year) ? Date::MONTH_DAYS_LEAP[month]? : Date::MONTH_DAYS[month]?
      raise Exception.new("Invalid month #{month}") if days_month.nil?
      days_month
    end

    def self.month_overflow?(year : Int32, month : Int32, day : Int32) : Bool
      day > days_in_month(year, month)
    end
  end
end
