Cronic
=======

Cronic is a natural language date/time parser written for Crystal. It is
primarily a port of Chronic (from Ruby) but with attempting to do things
the Crystal way.

See below for the wide variety of formats Cronic will parse.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cronic:
       github: nanobowers/cronic
   ```

2. Run `shards install`

## Usage

```crystal
require "cronic"
include Cronic

Time.now   #=> Sun Aug 27 23:18:25 PDT 2006

Cronic.parse("tomorrow")
  #=> Mon Aug 28 12:00:00 PDT 2006

Cronic.parse("monday", context: Direction::Past)
  #=> Mon Aug 21 12:00:00 PDT 2006

Cronic.parse("this tuesday 5:00")
  #=> Tue Aug 29 17:00:00 PDT 2006

Cronic.parse("this tuesday 5:00", ambiguous_time_range: nil)
  #=> Tue Aug 29 05:00:00 PDT 2006

Cronic.parse("may 27th", now: Time.local(2000, 1, 1))
  #=> Sat May 27 12:00:00 PDT 2000

Cronic.parse_span("may 27th")
  #=> Sun May 27 00:00:00 PDT 2007..Mon May 28 00:00:00 PDT 2007

Cronic.parse("6/4/2012", endian_precedence: DateEndian::DayMonth)
  #=> Fri Apr 06 00:00:00 PDT 2012

Cronic.parse("INVALID DATE")
  #=> nil
```

If the parser can find a date or time, either a Time or Cronic::Span
will be returned (depending on the value of `:guess`). If no
date or time can be found, `nil` will be returned.

See `Cronic.parse` for detailed usage instructions.

## Examples

Cronic can parse a huge variety of date and time formats. Following is a
small sample of strings that will be properly parsed. Parsing is case
insensitive and will handle common abbreviations and misspellings.

#### Simple

* thursday
* november
* summer
* friday 13:00
* mon 2:35
* 4pm
* 10 to 8
* 10 past 2
* half past 2
* 6 in the morning
* friday 1pm
* sat 7 in the evening
* yesterday
* today
* tomorrow
* last week
* next week
* this tuesday
* next month
* last winter
* this morning
* last night
* this second
* yesterday at 4:00
* last friday at 20:00
* last week tuesday
* tomorrow at 6:45pm
* afternoon yesterday
* thursday last week

#### Complex

* 3 years ago
* a year ago
* 5 months before now
* 7 hours ago
* 7 days from now
* 1 week hence
* in 3 hours
* 1 year ago tomorrow
* 3 months ago saturday at 5:00 pm
* 7 hours before tomorrow at noon
* 3rd wednesday in november
* 3rd month next year
* 3rd thursday this september
* 4th day last week
* fourteenth of june 2010 at eleven o'clock in the evening
* may seventh '97 at three in the morning

#### Specific Dates

* January 5
* 22nd of june
* 5th may 2017
* February twenty first
* dec 25
* may 27th
* October 2006
* oct 06
* jan 3 2010
* february 14, 2004
* february 14th, 2004
* 3 jan 2000
* 17 april 85
* 5/27/1979
* 27/5/1979
* 05/06
* 1979-05-27
* Friday
* 5
* 4:00
* 17:00
* 0800

#### Specific Times (many of the above with an added time)

* January 5 at 7pm
* 22nd of june at 8am
* 1979-05-27 05:00:00
* 03/01/2012 07:25:09.234567
* 2013-08-01T19:30:00.345-07:00
* 2013-08-01T19:30:00.34-07:00
* etc

## Contribute

If you'd like to hack on Cronic, start by forking the repo on GitHub:

https://github.com/nanobowers/cronic

## Contributing

The best way to get your changes merged back into core is as follows:

1. Fork it (<https://github.com/nanobowers/cronic/fork>)
2. Create a thoughtfully named topic branch to contain your change (`git checkout -b my-new-feature`)
3. Hack away
4. Add tests and make sure everything still passes by running `crystal spec`
5. Ensure your tests pass in multiple timezones. ie `TZ=utc crystal spec` `TZ=BST crystal spec`
6. If you are adding new functionality, document it in the README
7. Do not change the version number, we will do that on our end
8. If necessary, rebase your commits into logical chunks, without errors
9. Commit your changes (`git commit -am 'Add some feature'`)
10. Push to the branch (`git push origin my-new-feature`)
11. Create a new Pull Request

## Contributors

- [Ben Bowers](https://github.com/nanobowers) - creator and maintainer

Attribution for the original Chronic goes to @mojombo and countless others.

