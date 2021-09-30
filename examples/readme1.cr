#
# Examples from the readme
#

require "../src/cronic"
include Cronic

# Hijack param-less Time.local to force a specific time
struct Time
  def self.local
    self.local(2006, 8, 27, 23, 18, 25)
  end
end

p! Time.local                                                          # => 2006-08-27 23:18:25.0 -04:00 Local
p! Cronic.parse("tomorrow")                                            # => 2006-08-28 12:00:00.0 -04:00 Local
p! Cronic.parse("monday", context: PointerDir::Past)                   # => 2006-08-21 12:00:00.0 -04:00 Local
p! Cronic.parse("this tuesday 5:00")                                   # => 2006-08-29 17:00:00.0 -04:00 Local
p! Cronic.parse("this tuesday 5:00", ambiguous_time_range: nil)        # => 2006-08-29 05:00:00.0 -04:00 Local
p! Cronic.parse("may 27th", now: Time.local(2000, 1, 1))               # => 2000-05-27 12:00:00.0 -04:00 Local
p! Cronic.parse_span("may 27th")                                       # => (2007-05-27 00:00:00 -04:00..2007-05-28 00:00:00 -04:00)
p! Cronic.parse("6/4/2012", endian_precedence: [DateEndian::DayMonth]) # => 2012-04-06 12:00:00.0 -04:00 Local
p! Cronic.parse?("INVALID DATE")                                       # => nil
