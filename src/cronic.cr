require "number_parser" # aka numerizer

module Cronic
  # :nodoc:
  abstract class ParseError < Exception
  end

  # Raised when we try to parse an invalid date or time, mostly because
  # a certain span was exceeded.  e.g. "10th tuesday in january"
  class InvalidParseError < ParseError
  end

  # Raised when we try to parse an unknown string
  class UnknownParseError < ParseError
  end
end

require "./cronic/version"
require "./cronic/enums"
require "./cronic/date"
require "./cronic/time"

require "./cronic/handlers"
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

require "./cronic/definition"
require "./cronic/seq_matcher"
require "./cronic/parser"

# Parse natural language dates and times into `Time` or
# `Cronic::Timespan` objects.
#
# Examples:
# ```
# require "cronic"
#
# Time.local
# # => Sun Aug 27 23:18:25 PDT 2006
#
# Cronic.parse("tomorrow")
# # => Mon Aug 28 12:00:00 PDT 2006
#
# Cronic.parse("monday", context: PointerDir::Past)
# # => Mon Aug 21 12:00:00 PDT 2006
# ```
module Cronic
  @@debug : Bool = false

  # Enable debug-mode printing for `Cronic`
  class_property :debug

  # Parses a *text* String containing a natural language date or time.
  #
  # If the parser can find a date or time, a `Time`
  # will be returned (depending on the value of *guess*). If no
  # date/time can be found, `nil` will be returned.
  def self.parse(text, guess : Guess = Guess::Middle, **kwargs) : Time
    Parser.new(**kwargs).parse(text, guess: guess)
  end

  # Parses like `self.parse`, but will return `nil` if a `ParseError` is raised
  def self.parse?(*args, **kwargs) : Time?
    self.parse(*args, **kwargs)
  rescue ParseError
    nil
  end

  # Parses a *text* String containing natural language date or time.
  #
  # Similar to `self.parse`, but returns a `Cronic::Timespan` of the
  # begin-end time for the generated time-span instead of guessing a
  # specific time-point during that range.
  def self.parse_span(text, **kwargs) : Timespan
    Parser.new(**kwargs).parse_span(text)
  end

  # Construct a new `Time` object determining possible month overflows
  # and leap years.  Accounts for overflows in the values
  #
  # + *year*   - Int32 year.
  # + *month*  - Int32 month.
  # + *day*    - Int32 day.
  # + *hour*   - Int32 hour.
  # + *minute* - Int32 minute.
  # + *second* - Int32 second.
  #
  # Returns a new `Time` object constructed from these params.
  def self.construct(year : Int32, month : Int32 = 1, day : Int32 = 1, hour : Int32 = 0, minute : Int32 = 0, second : Int32 = 0, offset = nil) : Time
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

    # determine if there is a day overflow.
    # this is complicated by our crappy calendar
    # system (non-constant number of days per month)
    if day > 56
      raise Exception.new("Day must be no more than 56 (makes month resolution easier)")
    end

    if day > 28 # no month ever has fewer than 28 days, so only do this if necessary
      days_this_month = Date.days_in_month(year, month)
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

    Time.local(year, month, day, hour, minute, second)
  end
end
