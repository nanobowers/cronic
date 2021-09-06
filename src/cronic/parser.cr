require "./dictionary"
require "./handlers"

module Cronic
  class Parser
    include Handlers

    property :now
#    getter :options

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
          @context : Symbol = :future,
          @now : ::Time = ::Time.local,
          @hours24 : Bool? = nil,
          @week_start : Symbol = :sunday,
          @guess : Bool | Symbol = true,
          @ambiguous_time_range : Int = 6,
          @endian_precedence : Array(Symbol) = [:middle, :little],
          @ambiguous_year_future_bias : Int = 50
        )

    end

    # Parse "text" with the given options
    # Returns either a Time or Cronic::Span, depending on the value of options[:guess]
    def parse(text)
      tokens = tokenize(text) # , options
      span = tokens_to_span(tokens, text: text) # options.merge(text: text))
      if Cronic.debug
        sepline = "+" + ("-" * 51)
        puts sepline
        puts "| #{tokens}"
        puts sepline
      end
      guess(span, @guess) if span
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
    def pre_normalize(text)
      text = text.to_s.downcase
      text = text.gsub(/\b(\d{1,2})\.(\d{1,2})\.(\d{4})\b/, "\3 / \2 / \1")
      text = text.gsub(/\b([ap])\.m\.?/, "\1m")
      text = text.gsub(/(\s+|:\d{2}|:\d{2}\.\d+)\-(\d{2}:?\d{2})\b/, "\1tzminus\2")
      text = text.gsub(/\./, ":")
      text = text.gsub(/([ap]):m:?/, "\1m")
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
      text = text.gsub(/\bsecond (of|day|month|hour|minute|second|quarter)\b/, "2nd \1")
      text = text.gsub(/\bthird quarter\b/, "3rd q")
      text = text.gsub(/\bfourth quarter\b/, "4th q")
      text = text.gsub(/quarters?(\s+|$)(?!to|till|past|after|before)/, "q\1")
      text = NumberParser.parse(text)
      text = text.gsub(/\b(\d)(?:st|nd|rd|th)\s+q\b/, "q\1")
      text = text.gsub(/([\/\-\,\@])/) { " " + $1 + " " }
      text = text.gsub(/(?:^|\s)0(\d+:\d+\s*pm?\b)/, " \1")
      text = text.gsub(/\btoday\b/, "this day")
      text = text.gsub(/\btomm?orr?ow\b/, "next day")
      text = text.gsub(/\byesterday\b/, "last day")
      text = text.gsub(/\bnoon|midday\b/, "12:00pm")
      text = text.gsub(/\bmidnight\b/, "24:00")
      text = text.gsub(/\bnow\b/, "this second")
      text = text.gsub("quarter", "15")
      text = text.gsub("half", "30")
      text = text.gsub(/(\d{1,2}) (to|till|prior to|before)\b/, "\1 minutes past")
      text = text.gsub(/(\d{1,2}) (after|past)\b/, "\1 minutes future")
      text = text.gsub(/\b(?:ago|before(?: now)?)\b/, "past")
      text = text.gsub(/\bthis (?:last|past)\b/, "last")
      text = text.gsub(/\b(?:in|during) the (morning)\b/, "\1")
      text = text.gsub(/\b(?:in the|during the|at) (afternoon|evening|night)\b/, "\1")
      text = text.gsub(/\btonight\b/, "this night")
      text = text.gsub(/\b\d+:?\d*[ap]\b/,"\0m")
      text = text.gsub(/\b(\d{2})(\d{2})(am|pm)\b/, "\1:\2\3")
      text = text.gsub(/(\d)([ap]m|oclock)\b/, "\1 \2")
      text = text.gsub(/\b(hence|after|from)\b/, "future")
      text = text.gsub(/^\s?an? /i, "1 ")
      text = text.gsub(/\b(\d{4}):(\d{2}):(\d{2})\b/, "\1 / \2 / \3") # DTOriginal
      text = text.gsub(/\b0(\d+):(\d{2}):(\d{2}) ([ap]m)\b/, "\1:\2:\3 \4")
      text
    end

    # Guess a specific time within the given span.
    #
    # span - The Cronic::Span object to calcuate a guess from.
    #
    # Returns a new Time object.
    def guess(span : Span, mode = :middle)
      return span unless mode
      if (span.width > 1) && (mode == true || mode == :middle)
        return span.begin + ::Time::Span.new(seconds: span.width // 2)
      end
      return span.end if mode == :end
      span.begin
    end

    # List of Handler definitions. See Cronic.parse for a list of options this
    # method accepts.
    #
    # options - An optional Hash of configuration options.
    #
    # Returns a Hash of Handler definitions.
    def definitions(**kwargs)
      SpanDictionary.new(**kwargs).definitions
    end

    
    def tokenize(text, **options)
      text = pre_normalize(text)
      tokens = Tokenizer.tokenize(text)
      [Repeater, Grabber, Pointer, Scalar, Ordinal, Separator, Sign, TimeZone].each do |tok|
        tok.scan(tokens, **options)
      end
      tokens.select { |token| token.tagged? }
    end

    private def tokens_to_span(tokens, **options) : Span?
      definitions = definitions(**options)

      (definitions["endian"] + definitions["date"]).each do |handler|

        #pp! tokens
        
        if handler.match(tokens, definitions)
          good_tokens = tokens.select { |o| !o.get_tag Separator }
          return handler.invoke(:date, good_tokens, self, options)
        end
      end

      definitions["anchor"].each do |handler|
        if handler.match(tokens, definitions)
          good_tokens = tokens.select { |o| !o.get_tag Separator }
          return handler.invoke(:anchor, good_tokens, self, options)
        end
      end

      definitions["arrow"].each do |handler|
        if handler.match(tokens, definitions)
          good_tokens = tokens.reject { |o| o.get_tag(SeparatorAt) || o.get_tag(SeparatorSlash) || o.get_tag(SeparatorDash) || o.get_tag(SeparatorComma) || o.get_tag(SeparatorAnd) }
           return handler.invoke(:arrow, good_tokens, self, options)
        end
      end

      definitions["narrow"].each do |handler|
        if handler.match(tokens, definitions)
          return handler.invoke(:narrow, tokens, self, options)
        end
      end

      puts "-none" if Cronic.debug
      return nil
    end
  end
end
