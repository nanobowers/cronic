require "./dictionary"
require "./handlers"

module Cronic
  
  enum Guess
    Middle
    End
    Begin
  end
  
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
          @context : Symbol = :future,
          @now : Time = Time.local,
          @hours24 : Bool? = nil,
          @week_start : Time::DayOfWeek = Time::DayOfWeek::Sunday,
          #@guess : Cronic::Guess::Middle,
          @ambiguous_time_range : Int32|Symbol = 6,
          @endian_precedence : Array(Symbol) = [:middle, :little],
          @ambiguous_year_future_bias : Int = 50
        )

    end

    # Parse "text" with the given options
    # Returns either a Time or Cronic::Span, depending on the value of options[:guess]
    def parse(text, guess = Cronic::Guess::Middle)
      span = parse_span(text)
      guess(span, guess)
    end

    def parse_span(text) : SecSpan
      tokens = tokenize(text, context: @context,
                        now: @now,
                        hours24: @hours24,
                        #week_start: @week_start,
                        ambiguous_time_range: @ambiguous_time_range,
                        endian_precedence: @endian_precedence,
                        ambiguous_year_future_bias: @ambiguous_year_future_bias,
                       )
      span = tokens_to_span(tokens, text: text,
                            context: @context,
                            now: @now,
                            hours24: @hours24,
                            #week_start: @week_start,
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
    def pre_normalize(text)
      text = text.to_s.downcase


      text = text.gsub(/\b(\d{1,2})\.(\d{1,2})\.(\d{4})\b/, "\\3 / \\2 / \\1")

      # a.m, p.m. => am, pm
      text = text.gsub(/\b([ap])\.m\.?/, "\\1m")

      text = text.gsub(/t ( \d{2}:\d{2}:\d{2} (?:\.\d+)? ) (\S*) /xi) {
        ttime, zone = $1, $2
        # separate out T##:##:## ala rfc3339.  Convert "Z" to UTC
        fixzone = case zone
                  when "z", "Z" then "utc"
                  else zone
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
      text = NumberParser.parse(text)
      text = text.gsub(/\b(\d)(?:st|nd|rd|th)\s+q\b/, "q\\1")
      text = text.gsub(/([\/\-\,\@])/) { " " + $1 + " " }
      text = text.gsub(/(?:^|\s)0(\d+:\d+\s*pm?\b)/, " \\1")
      text = text.gsub(/\btoday\b/, "this day")
      text = text.gsub(/\btomm?orr?ow\b/, "next day")
      text = text.gsub(/\byesterday\b/, "last day")
      text = text.gsub(/\bnoon|midday\b/, "12:00pm")
      text = text.gsub(/\bmidnight\b/, "24:00")
      text = text.gsub(/\bnow\b/, "this second")
      text = text.gsub("quarter", "15")
      text = text.gsub("half", "30")
      text = text.gsub(/(\d{1,2}) (to|till|prior to|before)\b/, "\\1 minutes past")
      text = text.gsub(/(\d{1,2}) (after|past)\b/, "\\1 minutes future")
      text = text.gsub(/\b(?:ago|before(?: now)?)\b/, "past")
      text = text.gsub(/\bthis (?:last|past)\b/, "last")
      text = text.gsub(/\b(?:in|during) the (morning)\b/, "\\1")
      text = text.gsub(/\b(?:in the|during the|at) (afternoon|evening|night)\b/, "\\1")
      text = text.gsub(/\btonight\b/, "this night")
      text = text.gsub(/\b\d+:?\d*[ap]\b/,"\\0m")
      text = text.gsub(/\b(\d{2})(\d{2})(am|pm)\b/, "\\1:\\2\\3")
      text = text.gsub(/(\d)([ap]m|oclock)\b/, "\\1 \\2")
      text = text.gsub(/\b(hence|after|from)\b/, "future")
      text = text.gsub(/^\s?an? /i, "1 ")
      text = text.gsub(/\b(\d{4}):(\d{2}):(\d{2})\b/, "\\1 / \\2 / \\3") # DTOriginal
      text = text.gsub(/\b0(\d+):(\d{2}):(\d{2}) ([ap]m)\b/, "\\1:\\2:\\3 \\4")

      # improperly formatted -0100, +0500 tz adjusts
      text = text.gsub(/([+-]) (0[0-9]|1[0-2]) (\d{2})/x, " \\1\\2:\\3")
      p! text
      text
    end

    # Guess a specific time within the given `span`.
    def guess(span : SecSpan, mode : Guess = Guess::Middle) : Time
      if (span.width > 1) && (mode == Guess::Middle)
        span.begin + Time::Span.new(seconds: span.width // 2)
      elsif mode == Guess::End
        span.end
      else
        span.begin
      end
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

    def maybe(item)
      Or.new([item], maybe: true)
    end

    def or(item, item2)
      Or.new([item, item2], maybe: false)
    end

    def ormaybe(item, item2)
      Or.new([item, item2], maybe: true)
    end
    
    # sequence matcher
    def seqmatch(pattern, tokens) : Bool
      seq = Sequence.new(pattern)
      match(seq, tokens)
    end
    
    def match_one(pat, tok : Token)
      if pat.is_a?(Or)
        #puts ">> checking #{tok.inspect} against #{pat}"
        return pat.items.any? {|x| match_one(x, tok) }
      else
        #puts ">> checking #{tok.inspect} against #{pat}"
        return tok.tags.any? { |t| pat >= t.class }
      end
    end
    
    def match_maybe(pattern, tokens) : Bool
      if match_one(pattern.first, tokens.first) && match(pattern[1..], tokens[1..])
        return true
      else 
        return match(pattern[1..], tokens)
      end
    end
    
    def match(pattern, tokens) : Bool
      #puts ">> matching #{pattern.inspect}<<"
      if pattern.empty?
        return true if tokens.empty?
        return false
      elsif pattern.first.is_a?(Or)
        firstpat = pattern.first.as(Or)
        oritems = firstpat.items
        anyormatch = oritems.any? { |oritem|
          tokens.empty? ? false : match_one(oritem, tokens[0])
        }
        orclause = anyormatch && match(pattern[1..], tokens[1..])
        if orclause
          # if any of the or-cases plus the rest matched then good
          return true
        elsif firstpat.maybe?
          # if we had a maybe, then try the case where we skip the first
          # item in the pattern
          return match(pattern[1..], tokens)
        else
          false
        end
      elsif tokens.empty?
        return false # fail b/c no tokens left
      else
        return match_one(pattern[0], tokens[0]) && match(pattern[1..], tokens[1..])
      end
    end
  
    

    private def tokens_to_span(tokens, **opts) : SecSpan
      #definitions = definitions(**opts)

      good_tokens = tokens.select { |o| !o.has_tag Separator }
      slashdash = or(SeparatorSlash, SeparatorDash)
      maybetime = [maybe(RepeaterTime), maybe(RepeaterDayPortion)]

      # TODO: Generic needs to be replaced with a real handler for
      # Crystal since we do not have Ruby's Date.parse
      
      ## DATES
      date_defs = [
        {match: Sequence.new( [ScalarYear, SeparatorDash, ScalarMonth, SeparatorDash, ScalarDay, RepeaterTime, TimeZone] ), proc: ->(toks : Array(Token)){ handle_rfc3339(toks, **opts) }},
        {match: Sequence.new( [ScalarYear, SeparatorDash, ScalarMonth, SeparatorDash, ScalarDay, RepeaterTime] ), proc: ->(toks : Array(Token)){ handle_rfc3339_no_tz(toks, **opts) }},

      
      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, RepeaterTime, ormaybe(SeparatorSlash,SeparatorDash), TimeZone, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_sd_t_tz_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_sd_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_sd(toks, **opts) }},

      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_od_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_od(toks, **opts) }},

      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_sd(toks, **opts) }},
      {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rdn_rmn_od(toks, **opts) }},
      {match: Sequence.new([RepeaterDayName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rdn_od(toks, **opts) }},
      {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, ScalarDay, RepeaterTime, TimeZone]), proc: ->(toks : Array(Token)){ handle_generic(toks, **opts) }},
      {match: Sequence.new([OrdinalDay]), proc: ->(toks : Array(Token)){ handle_ordday(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, ScalarDay, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rmn_sd_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, OrdinalDay, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rmn_od_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, ScalarDay, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rmn_sd_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, OrdinalDay, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rmn_od_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, ormaybe(SeparatorSlash,SeparatorDash), ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rmn_sd(toks, **opts) }},

      {match: Sequence.new([RepeaterTime, maybe(RepeaterDayPortion), maybe(SeparatorOn), RepeaterMonthName, ScalarDay]), proc: ->(toks : Array(Token)){ handle_rmn_sd_on(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_rmn_od(toks, **opts) }},
      {match: Sequence.new([OrdinalDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_od_rmn_sy(toks, **opts) }},
      {match: Sequence.new([OrdinalDay, RepeaterMonthName, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_od_rmn(toks, **opts) }},
      {match: Sequence.new([OrdinalDay, maybe(Grabber), RepeaterMonth, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_od_rm(toks, **opts) }},

      {match: Sequence.new([ScalarYear, RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)){ handle_sy_rmn_od(toks, **opts) }},
      {match: Sequence.new([RepeaterTime, maybe(RepeaterDayPortion), maybe(SeparatorOn), RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)){ handle_rmn_od_on(toks, **opts) }},
      {match: Sequence.new([RepeaterMonthName, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rmn_sy(toks, **opts) }},
      {match: Sequence.new([RepeaterQuarterName, ScalarYear]), proc: ->(toks : Array(Token)){ handle_rqn_sy(toks, **opts) }},
      {match: Sequence.new([ScalarYear, RepeaterQuarterName]), proc: ->(toks : Array(Token)){ handle_sy_rqn(toks, **opts) }},
      {match: Sequence.new([ScalarDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sd_rmn_sy(toks, **opts) }},
      {match: Sequence.new([ScalarDay, ormaybe(SeparatorSlash, SeparatorDash), RepeaterMonthName, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sd_rmn(toks, **opts) }},
      {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sy_sm_sd(toks, **opts) }},
      {match: Sequence.new([ScalarYear, slashdash, ScalarMonth]), proc: ->(toks : Array(Token)){ handle_sy_sm(toks, **opts) }},
      {match: Sequence.new([ScalarMonth, slashdash, ScalarYear]), proc: ->(toks : Array(Token)){ handle_sm_sy(toks, **opts) }},
      {match: Sequence.new([ScalarDay, slashdash, RepeaterMonthName, slashdash, ScalarYear, maybe(RepeaterTime)]), proc: ->(toks : Array(Token)){ handle_sm_rmn_sy(toks, **opts) }},
      {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, maybe(Scalar), TimeZone]), proc: ->(toks : Array(Token)){ handle_generic(toks, **opts) }},
      ]
      
      ## ANCHORS
      anchor1 = [maybe(SeparatorOn), maybe(Grabber), Repeater, maybe(SeparatorAt), maybe(Repeater), maybe(Repeater)]
      anchor2 = [maybe(Grabber), Repeater, Repeater, maybe(Separator), maybe(Repeater), maybe(Repeater)]
      anchor3 = [Repeater, Grabber, Repeater]
      anchor_defs = [ 
      
      {match: Sequence.new(anchor1), proc: ->(toks : Array(Token)){ handle_r(toks, **opts) }},
      {match: Sequence.new(anchor2), proc: ->(toks : Array(Token)){ handle_r(toks, **opts) }},
      {match: Sequence.new(anchor3), proc: ->(toks : Array(Token)){ handle_r_g_r(toks, **opts) }},
      ]

      sr_and_srp_at = [Scalar, Repeater, maybe(SeparatorAnd), Scalar, Repeater, Pointer, maybe(SeparatorAt)]
      
      arrow_defs = [
      {match: Sequence.new([RepeaterMonthName, Scalar, Repeater, Pointer]), proc: ->(toks : Array(Token)){ handle_rmn_s_r_p(toks, **opts) }},
      {match: Sequence.new([Scalar, Repeater, Pointer]), proc: ->(toks : Array(Token)){ handle_s_r_p(toks, **opts) }},
      # {match: Sequence.new([Scalar, Repeater, maybe(SeparatorAnd), Scalar, Repeater, Pointer, maybe(SeparatorAt), Anchor]), proc: ->(toks : Array(Token)){ handle_s_r_a_s_r_p_a(toks, **opts) }},
      {match: Sequence.new( sr_and_srp_at + anchor1), proc: ->(toks : Array(Token)){ handle_s_r_a_s_r_p_a(toks, **opts) }},
      {match: Sequence.new( sr_and_srp_at + anchor2), proc: ->(toks : Array(Token)){ handle_s_r_a_s_r_p_a(toks, **opts) }},
      {match: Sequence.new( sr_and_srp_at + anchor3), proc: ->(toks : Array(Token)){ handle_s_r_a_s_r_p_a(toks, **opts) }},
      
      {match: Sequence.new([Pointer, Scalar, Repeater]), proc: ->(toks : Array(Token)){ handle_p_s_r(toks, **opts) }},

      # {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), Anchor]), proc: ->(toks : Array(Token)){ handle_s_r_p_a(toks, **opts) }},
      {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor1]), proc: ->(toks : Array(Token)){ handle_s_r_p_a(toks, **opts) }},
      {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor2]), proc: ->(toks : Array(Token)){ handle_s_r_p_a(toks, **opts) }},
      {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor3]), proc: ->(toks : Array(Token)){ handle_s_r_p_a(toks, **opts) }},
      
      ]
      
      narrow_defs = [
        {match: Sequence.new([Ordinal, Repeater, SeparatorIn, Repeater]), proc: ->(toks : Array(Token)){ handle_o_r_s_r(toks, **opts) }},
        {match: Sequence.new([Ordinal, Repeater, Grabber, Repeater]), proc: ->(toks : Array(Token)){ handle_o_r_g_r(toks, **opts) }},
      ]
      
      endian_defs = [
      {match: Sequence.new([ScalarMonth, slashdash, ScalarDay, slashdash, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sm_sd_sy(toks, **opts) }},
      {match: Sequence.new([ScalarMonth, slashdash, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sm_sd(toks, **opts) }},
      {match: Sequence.new([ScalarDay, slashdash, ScalarMonth, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sd_sm(toks, **opts) }},
      {match: Sequence.new([ScalarDay, slashdash, ScalarMonth, slashdash, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sd_sm_sy(toks, **opts) }},
      {match: Sequence.new([ScalarDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)){ handle_sd_rmn_sy(toks, **opts) }}
      ]

      ######
      
      span : SecSpan? = nil
      
      ordered_endian_defs = @endian_precedence.first == :little ? endian_defs.reverse : endian_defs
      defs = ordered_endian_defs + date_defs + anchor_defs

      defs.each_with_index do |defn, idx|
        if span.nil? && (hadmatch = match(defn[:match], tokens))
          puts "#{idx} #{hadmatch} #{tokens.map(&.to_s)} #{defn[:match].items}\n\n"
          span = defn[:proc].call(good_tokens)
        end
      end

      arrow_defs.each do |defn|
        if span.nil? && ( hadmatch = match(defn[:match], tokens) )
          arrow_good_tokens = tokens.reject { |o| o.get_tag(SeparatorAt) || o.get_tag(SeparatorSlash) || o.get_tag(SeparatorDash) || o.get_tag(SeparatorComma) || o.get_tag(SeparatorAnd) }
          span = defn[:proc].call(arrow_good_tokens)
        end
      end
      narrow_defs.each do |defn|
        if span.nil? && ( hadmatch = match(defn[:match], tokens) )
          puts "NARROW #{hadmatch} #{tokens.map(&.to_s)} #{defn[:match].items}\n\n"
          span = defn[:proc].call(tokens)
        end
      end
      
      if span.is_a?(SecSpan)
        return span
      else
        
        raise UnknownParseError.new("Failed to match tokens against any known patterns #{tokens.map(&.to_s)}")
      end
#      
#      (definitions["endian"] + definitions["date"]).each do |handler|
#
#        #pp! tokens
#        
#        if handler.match(tokens, definitions)
#          good_tokens = tokens.select { |o| !o.get_tag Separator }
#          return handler.invoke(:date, good_tokens, self, opts)
#        end
#      end
#
#      definitions["anchor"].each do |handler|
#        if handler.match(tokens, definitions)
#          good_tokens = tokens.select { |o| !o.get_tag Separator }
#          return handler.invoke(:anchor, good_tokens, self, opts)
#        end
#      end
#
#      definitions["arrow"].each do |handler|
#        if handler.match(tokens, definitions)
#          good_tokens = tokens.reject { |o| o.get_tag(SeparatorAt) || o.get_tag(SeparatorSlash) || o.get_tag(SeparatorDash) || o.get_tag(SeparatorComma) || o.get_tag(SeparatorAnd) }
#           return handler.invoke(:arrow, good_tokens, self, opts)
#        end
#      end
#
#      definitions["narrow"].each do |handler|
#        if handler.match(tokens, definitions)
#          return handler.invoke(:narrow, tokens, self, opts)
#        end
#      end
#
#      puts "-none" if Cronic.debug
#      return nil
    end
  end
end
