module Cronic
  class Parser
    include Handlers
    property :now

    # options - An optional Hash of configuration options:
    #        :context - If your string represents a birthday, you can set
    #                   this value to :past and if an ambiguous string is
    #                   given, it will assume it is in the past.
    #        :now - Time, all computations will be based off of time
    #               instead of Time.now.
    #        :hours24 - Time will be parsed as it would be 24 hour clock.
    #        :week_start - By default, the parser assesses weeks start on
    #                  sunday but you can change this value to :monday if
    #                  needed.
    #        :guess - By default the parser will guess a single point in time
    #                 for the given date or time. If you'd rather have the
    #                 entire time span returned, set this to false
    #                 and a Cronic::Span will be returned. Setting :guess to :end
    #                 will return last time from Span, to :middle for middle (same as just true)
    #                 and :begin for first time from span.
    #        :ambiguous_time_range - If an Integer is given, ambiguous times
    #                  (like 5:00) will be assumed to be within the range of
    #                  that time in the AM to that time in the PM. For
    #                  example, if you set it to `7`, then the parser will
    #                  look for the time between 7am and 7pm. In the case of
    #                  5:00, it would assume that means 5:00pm. If `:none`
    #                  is given, no assumption will be made, and the first
    #                  matching instance of that time will be used.
    #        :endian_precedence - By default, Cronic will parse "03/04/2011"
    #                 as the fourth day of the third month. Alternatively you
    #                 can tell Cronic to parse this as the third day of the
    #                 fourth month by setting this to [:little, :middle].
    #        :ambiguous_year_future_bias - When parsing two digit years
    #                 (ie 79) unlike Rubys Time class, Cronic will attempt
    #                 to assume the full year using this figure. Cronic will
    #                 look x amount of years into the future and past. If the
    #                 two digit year is `now + x years` it's assumed to be the
    #                 future, `now - x years` is assumed to be the past.
    def initialize(
      @context : PointerDir = PointerDir::Future,
      @now : Time = Time.local,
      @hours24 : Bool? = nil,
      @week_start : Time::DayOfWeek = Time::DayOfWeek::Sunday,
      @ambiguous_time_range : Int32? = 6,
      @endian_precedence : Array(DateEndian) = [DateEndian::MonthDay, DateEndian::DayMonth],
      @ambiguous_year_future_bias : Int = 50
    )
    end

    # Parse "text" with the given options
    # Returns either a Time or Cronic::Span, depending on the value of options[:guess]
    def parse(text, guess = Cronic::Guess::Middle)
      span = parse_span(text)
      guess(span, guess)
    end

    # Parse text into a Span
    def parse_span(text) : SecSpan
      tokens = tokenize(text, context: @context,
        now: @now,
        hours24: @hours24,
        week_start: @week_start,
        ambiguous_time_range: @ambiguous_time_range,
        endian_precedence: @endian_precedence,
        ambiguous_year_future_bias: @ambiguous_year_future_bias,
      )
      span = tokens_to_span(tokens, text: text,
        context: @context,
        now: @now,
        hours24: @hours24,
        ambiguous_time_range: @ambiguous_time_range,
        endian_precedence: @endian_precedence,
        ambiguous_year_future_bias: @ambiguous_year_future_bias,
      )
      if Cronic.debug
        sepline = "+" + ("-" * 51)
        puts sepline
        puts "| #{tokens}"
        puts sepline
      end
      span
    end

    # Clean up the specified text ready for parsing.
    #
    # Clean up the string by stripping unwanted characters, converting
    # idioms to their canonical form, converting number words to numbers
    # (three => 3), and converting ordinal words to numeric
    # ordinals (third => 3rd)
    #
    # text - The String text to normalize.
    #
    # Examples:
    #
    #   Cronic.pre_normalize('first day in May')
    #     #=> "1st day in may"
    #
    #   Cronic.pre_normalize('tomorrow after noon')
    #     #=> "next day future 12:00"
    #
    #   Cronic.pre_normalize('one hundred and thirty six days from now')
    #     #=> "136 days future this second"
    #
    # Returns a new String ready for Cronic to parse.
    def pre_normalize(text) : String
      text = text.to_s.downcase

      text = text.gsub(/\b(\d{1,2})\.(\d{1,2})\.(\d{4})\b/, "\\3 / \\2 / \\1")
      text = text.gsub(/\b(\d{1,2})\.(\d{1,2})\.(\d{2})\b/, "\\2 / \\1 / \\3") # Chronic.rb#356 / 2-digit euro-date-format

      # a.m, p.m. => am, pm
      text = text.gsub(/\b([ap])\.m\.?/, "\\1m")

      text = text.gsub(/t ( \d{2}:\d{2}:\d{2} (?:\.\d+)? ) (\S*) /xi) {
        ttime, zone = $1, $2
        # separate out T##:##:## ala rfc3339.  Convert "Z" to UTC
        fixzone = case zone
                  when "z", "Z" then "utc"
                  else               zone
                  end
        " #{ttime} " + fixzone
      }

      text = text.gsub(/(\s+|:\d{2}|:\d{2}\.\d+)\-(\d{2}:?\d{2})\b/, "\\1tzminus\\2")
      text = text.gsub(/(\s+|:\d{2}|:\d{2}\.\d+)Z\b/, "\\1 utc")
      text = text.gsub(/\./, ":")
      text = text.gsub(/([ap]):m:?/, "\\1m")
      text = text.gsub(/'(\d{2})\b/) do
        number = $1.to_i
        if Cronic::Date.could_be_year?(number)
          Cronic::Date.make_year(number, @ambiguous_year_future_bias)
        else
          number
        end
      end
      text = text.gsub(/['"]/, "")
      text = text.gsub(/,/, " ")
      text = text.gsub(/^second /, "2nd ")
      text = text.gsub(/\bsecond (of|day|month|hour|minute|second|quarter)\b/, "2nd \\1")
      text = text.gsub(/\bthird quarter\b/, "3rd q")
      text = text.gsub(/\bfourth quarter\b/, "4th q")
      text = text.gsub(/quarters?(\s+|$)(?!to|till|past|after|before)/, "q\\1")

      # Before NumberParser so that half/quarter is not converted to "1/2" or "1/4"
      text = text.gsub(/quarter (to|till|prior to|before)\b/, "15 minutes past")
      text = text.gsub(/quarter (after|past)\b/, "15 minutes future")
      text = text.gsub(/half (to|till|prior to|before)\b/, "30 minutes past")
      text = text.gsub(/half (after|past)\b/, "30 minutes future")

      text = NumberParser.parse(text, bias: :ordinal, ignore: ["second", "quarter"])
      text = text.gsub(/\b(\d)(?:st|nd|rd|th)\s+q\b/, "q\\1")
      text = text.gsub(/([\/\-\,\@])/) { " " + $1 + " " }
      text = text.gsub(/(?:^|\s)0(\d+:\d+\s*pm?\b)/, " \\1")
      text = text.gsub(/\btoday\b/, "this day")
      text = text.gsub(/\btomm?orr?ow\b/, "next day")
      text = text.gsub(/\byesterday\b/, "last day")
      text = text.gsub(/\bnoon|midday\b/, "12:00pm")
      text = text.gsub(/\bmidnight\b/, "24:00")
      text = text.gsub(/\bnow\b/, "this second")

      text = text.gsub(/(\d{1,2}) (to|till|prior to|before)\b/, "\\1 minutes past")
      text = text.gsub(/(\d{1,2}) (after|past)\b/, "\\1 minutes future")
      text = text.gsub(/\b(?:ago|before(?: now)?)\b/, "past")
      text = text.gsub(/\bthis (?:last|past)\b/, "last")
      text = text.gsub(/\b(?:in|during) the (morning)\b/, "\\1")
      text = text.gsub(/\b(?:in) an? (second|minute|hour|day|week|month|year)\b/, "in 1 \\1")
      text = text.gsub(/\b(?:in the|during the|at) (afternoon|evening|night)\b/, "\\1")
      text = text.gsub(/\btonight\b/, "this night")
      text = text.gsub(/\b\d+:?\d*[ap]\b/, "\\0m")
      text = text.gsub(/\b(\d{2})(\d{2})(am|pm)\b/, "\\1:\\2\\3")
      text = text.gsub(/(\d)([ap]m|oclock)\b/, "\\1 \\2")
      text = text.gsub(/\b(hence|after|from)\b/, "future")
      text = text.gsub(/^\s?an? /i, "1 ")
      text = text.gsub(/\b(\d{4}):(\d{2}):(\d{2})\b/, "\\1 / \\2 / \\3") # DTOriginal
      text = text.gsub(/\b0(\d+):(\d{2}):(\d{2}) ([ap]m)\b/, "\\1:\\2:\\3 \\4")

      # improperly formatted -0100, +0500 tz adjusts
      text = text.gsub(/([+-]) (0[0-9]|1[0-2]) (\d{2})/x, " \\1\\2:\\3")

      text
    end

    # Guess a specific time within the given `span`.
    def guess(span : SecSpan, mode : Guess = Guess::Middle) : Time
      if (span.width > 1) && (mode == Guess::Middle)
        span.middle
      elsif mode == Guess::End
        span.end
      else
        span.begin
      end
    end

    # Process text into tagged tokens
    def tokenize(text, **options) : Array(Token)
      text = pre_normalize(text)
      tokens = Tokenizer.tokenize(text)
      [Repeater, Grabber, Pointer, Scalar, Ordinal, Separator, Sign, TimeZone].each do |tok|
        tok.scan(tokens, **options)
      end
      tokens.select { |token| token.tagged? }
    end

    private def tokens_to_span(tokens, **opts) : SecSpan
      date_defs = DateDefinitions.new(@now).definitions(**opts)
      anchor_defs = AnchorDefinitions.new(@now).definitions(**opts)
      arrow_defs = ArrowDefinitions.new(@now).definitions(**opts)
      narrow_defs = NarrowDefinitions.new(@now).definitions(**opts)
      endian_defs = EndianDefinitions.new(@now).definitions(**opts)

      good_tokens = tokens.select { |o| !o.has_tag Separator }

      # TODO: Generic needs to be replaced with a real handler for
      # Crystal since we do not have Ruby's Date.parse

      span : SecSpan? = nil

      defs = endian_defs + date_defs + anchor_defs

      defs.each_with_index do |defn, idx|
        if span.nil? && (hadmatch = SeqMatcher.match(defn[:match], tokens))
          # puts "#{idx} #{hadmatch} #{tokens.map(&.to_s)} #{defn[:match].items}\n\n" if Cronic.debug
          span = defn[:proc].call(good_tokens)
        end
      end

      arrow_defs.each do |defn|
        if span.nil? && (hadmatch = SeqMatcher.match(defn[:match], tokens))
          arrow_good_tokens = tokens.reject { |o| o.get_tag(SeparatorAt) || o.get_tag(SeparatorSlash) || o.get_tag(SeparatorDash) || o.get_tag(SeparatorComma) || o.get_tag(SeparatorAnd) }
          span = defn[:proc].call(arrow_good_tokens)
        end
      end

      narrow_defs.each do |defn|
        if span.nil? && (hadmatch = SeqMatcher.match(defn[:match], tokens))
          # puts "NARROW #{hadmatch} #{tokens.map(&.to_s)} #{defn[:match].items}\n\n" if Cronic.debug
          span = defn[:proc].call(tokens)
        end
      end

      if span.is_a?(SecSpan)
        return span
      else
        raise UnknownParseError.new("Failed to match tokens against any known patterns #{tokens.map(&.to_s)}")
      end
    end
  end
end
