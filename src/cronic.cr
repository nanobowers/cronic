require "number_parser" # aka numerizer

module Cronic
  # Raised when we try to parse an invalid date or time
  class InvalidParseError < Exception
  end
end

require "./cronic/version"
require "./cronic/date"
require "./cronic/time"

require "./cronic/handler"
require "./cronic/handlers"
require "./cronic/mini_date"
require "./cronic/span"
require "./cronic/token"
require "./cronic/tokenizer"
require "./cronic/season"

require "./cronic/tag"
require "./cronic/tags/grabber"
require "./cronic/tags/ordinal"
require "./cronic/tags/pointer"
require "./cronic/tags/scalar"
require "./cronic/tags/separator"
require "./cronic/tags/sign"
require "./cronic/tags/time_zone"

require "./cronic/tags/repeater"
require "./cronic/repeaters/repeater_year"
require "./cronic/repeaters/repeater_quarter"
require "./cronic/repeaters/repeater_quarter_name"
require "./cronic/repeaters/repeater_season"
require "./cronic/repeaters/repeater_season_name"
require "./cronic/repeaters/repeater_month"
require "./cronic/repeaters/repeater_month_name"
require "./cronic/repeaters/repeater_fortnight"
require "./cronic/repeaters/repeater_week"
require "./cronic/repeaters/repeater_weekend"
require "./cronic/repeaters/repeater_weekday"
require "./cronic/repeaters/repeater_day"
require "./cronic/repeaters/repeater_day_name"
require "./cronic/repeaters/repeater_day_portion"
require "./cronic/repeaters/repeater_hour"
require "./cronic/repeaters/repeater_minute"
require "./cronic/repeaters/repeater_second"
require "./cronic/repeaters/repeater_time"

require "./cronic/parser"

# Parse natural language dates and times into Time or Cronic::Span objects.
#
# Examples:
#
#   require "cronic"
#
#   Time.local   #=> Sun Aug 27 23:18:25 PDT 2006
#
#   Cronic.parse("tomorrow")
#     #=> Mon Aug 28 12:00:00 PDT 2006
#
#   Cronic.parse("monday", context: :past)
#     #=> Mon Aug 21 12:00:00 PDT 2006
module Cronic

  @@debug : Bool = false

  # Returns true when debug mode is enabled.
  def self.debug
    @@debug
  end
  def self.debug=(val : Bool)
    @@debug=val
  end
  
#KILL  property :time_class
#K  time_class = ::Time


  # Parses a string containing a natural language date or time.
  #
  # If the parser can find a date or time, a Time 
  # will be returned (depending on the value of `guess:`). If no
  # date/time can be found, `nil` will be returned.
  #
  # text - The String text to parse.
  def self.parse(text, guess : Guess = Guess::Middle, **kwargs)
    Parser.new(**kwargs).parse(text, guess: guess)
  end

  # Parses a String containing natural language date or time.
  # Similar to self.parse, but returns a Cronic::SecSpan of the
  # begin-end time for the generated time-span instead of guessing a
  # specific time-point during that range.
  def self.parse_span(text, **kwargs)
    Parser.new(**kwargs).parse_span(text)
  end

  # Construct a new time object determining possible month overflows
  # and leap years.
  #
  # year   - Integer year.
  # month  - Integer month.
  # day    - Integer day.
  # hour   - Integer hour.
  # minute - Integer minute.
  # second - Integer second.
  #
  # Returns a new Time object constructed from these params.
  def self.construct(year : Int32, month : Int32 = 1, day : Int32  = 1, hour : Int32  = 0, minute : Int32  = 0, second : Int32  = 0, offset = nil) : ::Time
    if second >= 60
      minute += second // 60
      second = second % 60
    end

    if minute >= 60
      hour += minute // 60
      minute = minute % 60
    end

    if hour >= 24
      day += hour // 24
      hour = hour % 24
    end

    # determine if there is a day overflow. this is complicated by our crappy calendar
    # system (non-constant number of days per month)
    day <= 56 || raise("day must be no more than 56 (makes month resolution easier)")
    if day > 28 # no month ever has fewer than 28 days, so only do this if necessary
      days_this_month = Time.leap_year?(year) ? Date::MONTH_DAYS_LEAP[month] : Date::MONTH_DAYS[month]
      days_this_month = days_this_month.as(Int32)
      if day > days_this_month
        month += day // days_this_month
        day = day % days_this_month
      end
    end

    if month > 12
      if month % 12 == 0
        year += (month - 12) // 12
        month = 12
      else
        year += month // 12
        month = month % 12
      end
    end

    #if Cronic.time_class.name == "Date"
    #  Cronic.time_class.new(year, month, day)
    #elsif not Cronic.time_class.respond_to?(:new) or (RUBY_VERSION.to_f < 1.9 and Cronic.time_class.name == "Time")
    #  Cronic.time_class.local(year, month, day, hour, minute, second)
    #else
    #  offset = Time::normalize_offset(offset) if Cronic.time_class.name == "DateTime"
    #  Cronic.time_class.new(year, month, day, hour, minute, second, offset)
    #end
    ::Time.local(year, month, day, hour, minute, second)
  end

end
