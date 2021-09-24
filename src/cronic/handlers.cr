module Cronic
  module Handlers
    # Handle month/day
    def subhandle_m_d(month, day, time_tokens, context = PointerDir::None, **options)
      month.start = self.now
      span = month.this(context)
      year, month = span.begin.year, span.begin.month
      day_start = Time.local(year, month, day)
      day_start = Time.local(year + 1, month, day) if context == PointerDir::Future && day_start < now

      day_or_time(day_start, time_tokens, **options)
    end

    # Handle repeater-month-name/scalar-day
    def handle_rmn_sd(tokens, **options)
      month = tokens[0].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[1].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)

      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[2..], **options)
    end

    # Handle repeater-month-name/scalar-day with separator-on
    def handle_rmn_sd_on(tokens, **options)
      if tokens.size > 3
        month = tokens[2].get_tag(RepeaterMonthName).as(RepeaterMonthName)
        day = tokens[3].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
        token_range = 0..1
      else
        month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
        day = tokens[2].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
        token_range = 0..0
      end

      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[token_range], **options)
    end

    # Handle repeater-month-name/ordinal-day
    def handle_rmn_od(tokens, **options)
      month = tokens[0].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[1].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)

      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[2..tokens.size], **options)
    end

    # Handle ordinal this month
    def handle_od_rm(tokens, **options)
      day = tokens[0].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      month = tokens[2].get_tag(RepeaterMonth).as(RepeaterMonth)
      subhandle_m_d(month, day, tokens[3..tokens.size], **options)
    end

    # Handle ordinal-day/repeater-month-name
    def handle_od_rmn(tokens, **options) : SecSpan?
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[0].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[2..tokens.size], **options)
    end

    def handle_sy_rmn_od(tokens, **options)
      year = tokens[0].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      day = tokens[2].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)
        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle scalar-day/repeater-month-name
    def handle_sd_rmn(tokens, **options)
      # pp! tokens
      day = tokens[0].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)

      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[2..tokens.size], **options)
    end

    # Handle repeater-month-name/ordinal-day with separator-on
    def handle_rmn_od_on(tokens, **options)
      if tokens.size > 3
        month = tokens[2].get_tag(RepeaterMonthName).as(RepeaterMonthName)
        day = tokens[3].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
        token_range = 0..1
      else
        month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
        day = tokens[2].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
        token_range = 0..0
      end

      return nil if Date.month_overflow?(self.now.year, month.index, day)
      subhandle_m_d(month, day, tokens[token_range], **options)
    end

    # Handle scalar-year/repeater-quarter-name
    def handle_sy_rqn(tokens, **options)
      handle_rqn_sy(tokens[0..1].reverse, **options)
    end

    # Handle repeater-quarter-name/scalar-year
    def handle_rqn_sy(tokens, **options)
      year = tokens[1].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      quarter_tag = tokens[0].get_tag(RepeaterQuarterName).as(RepeaterQuarterName)
      quarter_tag.start = Cronic.construct(year)
      quarter_tag.this(PointerDir::None)
    end

    # Handle repeater-month-name/scalar-year
    def handle_rmn_sy(tokens, **options)
      month = tokens[0].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      year = tokens[1].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)

      if month == 12
        next_month_year = year + 1
        next_month_month = 1
      else
        next_month_year = year
        next_month_month = month + 1
      end

      begin
        end_time = Time.local(next_month_year, next_month_month, 1)
        SecSpan.new(Time.local(year, month, 1), end_time)
      rescue ArgumentError
        nil
      end
    end

    def handle_rfc3339(tokens, text = "", **options)
      # reconstruct rfc3339 in case it's malformatted
      raise Exception.new("Expected 5 tokens, busted..") unless tokens.size == 5
      # date: YYYY-MM-DD
      date = tokens[0].word + "-" + tokens[1].word + "-" + tokens[2].word
      # time (incl subseconds) is separated by ":", so fix to "." for subseconds
      timetoks = tokens[3].word.split(":")
      time = if timetoks.size == 4
               timetoks[0..-2].join(":") + "." + timetoks[-1]
             else
               tokens[3].word
             end
      # query timezone format from tag
      tz = tokens[4].get_tag(TimeZone).as(TimeZone).zone.format
      newtext = date + "T" + time + tz
      # p ["full-rfc3339!!", text, newtext]
      t = Time.parse_rfc3339(newtext)
      SecSpan.new(t, t + 1.second)
    end

    # timestamp similar to rfc3339 but without trailing timezone
    def xxhandle_rfc3339_no_tz(tokens, text = "", **options)
      date = tokens[0].word + "-" + tokens[1].word + "-" + tokens[2].word
      # time (incl subseconds) is separated by ":", so fix to "." for subseconds
      timetoks = tokens[3].word.split(":")
      newtext = date + "T" + tokens[3].word
      t = if timetoks.size == 4
            Time.parse(newtext, "%Y-%m-%dT%H:%M:%S:%N", Time::Location.local)
          else
            Time.parse(newtext, "%Y-%m-%dT%H:%M:%S", Time::Location.local)
          end
      # p ["part-rfc3339!!", text, newtext]
      SecSpan.new(t, t + 1.second)
    end

    # Actually SY-SM-SD-RT
    def handle_rfc3339_no_tz(tokens, text = "", **options)
      year = tokens[0].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      month = tokens[1].get_tag(ScalarMonth).as(ScalarMonth).type.as(Int32)
      day = tokens[2].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      timesecs = tokens[3].get_tag(RepeaterTime).as(RepeaterTime).tagtype.as(Tick).timespan
      # p timesecs
      t = Time.local(year, month, day) + timesecs
      SecSpan.new(t, t + 1.second)
    end

    def handle_rdn_rmn_sd_t_tz_sy(tokens, text = "", **opts)
      year = tokens[5].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      day = tokens[2].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      timesecs = tokens[3].get_tag(RepeaterTime).as(RepeaterTime).tagtype.as(Tick).timespan
      tz = tokens[4].get_tag(TimeZone).as(TimeZone).zone
      t = Time.utc(year, month, day) + timesecs - tz.offset.seconds
      SecSpan.new(t, t + 1.second)
    end

    # Handle generic timestamp
    def handle_generic(tokens, text = "", **options)
      # p! ["generic!!", text]
      # guaranteed to not work since Crystal Time.parse way diff than ruby Time.parse
      t = Time.parse!(text, "%Y-%m-%d")
      SecSpan.new(t, t + 1.second)
    rescue ex : Time::Format::Error
      return nil
    rescue e : ArgumentError
      raise e unless e.message =~ /out of range/
    end

    def handle_ordday(tokens, text = "", **options)
      day_num = tokens[0].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      t = Time.local(Time.local.year, Time.local.month, day_num)
      SecSpan.new(t, t + 1.second)
    end

    # Handle repeater-month-name/scalar-day/scalar-year
    def handle_rmn_sd_sy(tokens, **options)
      month = tokens[0].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      day = tokens[1].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      year = tokens[2].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)
        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle repeater-month-name/ordinal-day/scalar-year
    def handle_rmn_od_sy(tokens, **options)
      month = tokens[0].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      day = tokens[1].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      year = tokens[2].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)
        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle oridinal-day/repeater-month-name/scalar-year
    def handle_od_rmn_sy(tokens, **options)
      day = tokens[0].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      year = tokens[2].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)
        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle scalar-day/repeater-month-name/scalar-year
    def handle_sd_rmn_sy(tokens, **options)
      new_tokens = [tokens[1], tokens[0], tokens[2]]
      time_tokens = tokens.last(tokens.size - 3)
      handle_rmn_sd_sy(new_tokens + time_tokens, **options)
    end

    # Handle scalar-month/scalar-day/scalar-year (endian middle)
    def handle_sm_sd_sy(tokens, **options)
      month = tokens[0].get_tag(ScalarMonth).as(ScalarMonth).type.as(Int32)
      day = tokens[1].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      year = tokens[2].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      time_tokens = tokens[3..] # tokens.last(tokens.size - 3)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)
        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle scalar-day/scalar-month/scalar-year (endian little)
    def handle_sd_sm_sy(tokens, **options)
      new_tokens = [tokens[1], tokens[0], tokens[2]]
      time_tokens = tokens.last(tokens.size - 3)
      handle_sm_sd_sy(new_tokens + time_tokens, **options)
    end

    # Handle scalar-year/scalar-month/scalar-day
    def handle_sy_sm_sd(tokens, **options)
      new_tokens = [tokens[1], tokens[2], tokens[0]]
      time_tokens = tokens.last(tokens.size - 3)
      handle_sm_sd_sy(new_tokens + time_tokens, **options)
    end

    # Handle scalar-month/scalar-day
    def handle_sm_sd(tokens, context = PointerDir::Future, **options)
      month = tokens[0].get_tag(ScalarMonth).as(ScalarMonth).type.as(Int32)
      day = tokens[1].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      year = self.now.year
      time_tokens = tokens.last(tokens.size - 2)

      return nil if Date.month_overflow?(year, month, day)

      begin
        day_start = Time.local(year, month, day)

        if context == PointerDir::Future && day_start < now
          day_start = Time.local(year + 1, month, day)
        elsif context == PointerDir::Past && day_start > now
          day_start = Time.local(year - 1, month, day)
        end

        day_or_time(day_start, time_tokens, **options)
      rescue ArgumentError
        nil
      end
    end

    # Handle scalar-day/scalar-month
    def handle_sd_sm(tokens, **options)
      new_tokens = [tokens[1], tokens[0]]
      time_tokens = tokens.last(tokens.size - 2)
      handle_sm_sd(new_tokens + time_tokens, **options)
    end

    def handle_year_and_month(year : Int32, month : Int32)
      if month == 12
        next_month_year = year + 1
        next_month_month = 1
      else
        next_month_year = year
        next_month_month = month + 1
      end

      begin
        end_time = Time.local(next_month_year, next_month_month, 1)
        SecSpan.new(Time.local(year, month, 1), end_time)
      rescue ArgumentError
        nil
      end
    end

    # Handle scalar-month/scalar-year
    def handle_sm_sy(tokens, **options)
      month = tokens[0].get_tag(ScalarMonth).as(ScalarMonth).type.as(Int32)
      year = tokens[1].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      handle_year_and_month(year, month)
    end

    # Handle scalar-year/scalar-month
    def handle_sy_sm(tokens, **options)
      year = tokens[0].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      month = tokens[1].get_tag(ScalarMonth).as(ScalarMonth).type.as(Int32)
      handle_year_and_month(year, month)
    end

    # Handle RepeaterDayName RepeaterMonthName OrdinalDay
    def handle_rdn_rmn_od(tokens, **options)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[2].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)
      year = self.now.year

      return nil if Date.month_overflow?(year, month.index, day)

      begin
        if time_tokens.empty?
          start_time = Time.local(year, month.index, day)
          end_time = time_with_rollover(year, month.index, day + 1)
          SecSpan.new(start_time, end_time)
        else
          day_start = Time.local(year, month.index, day)
          day_or_time(day_start, time_tokens, **options)
        end
      rescue ArgumentError
        nil
      end
    end

    # Handle RepeaterDayName RepeaterMonthName OrdinalDay ScalarYear
    def handle_rdn_rmn_od_sy(tokens, **options)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[2].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)
      year = tokens[3].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)

      return nil if Date.month_overflow?(year, month.index, day)

      begin
        start_time = Time.local(year, month.index, day)
        end_time = time_with_rollover(year, month.index, day + 1)
        SecSpan.new(start_time, end_time)
      rescue ArgumentError
        nil
      end
    end

    # Handle RepeaterDayName OrdinalDay
    def handle_rdn_od(tokens, context = PointerDir::Future, **options)
      day = tokens[1].get_tag(OrdinalDay).as(OrdinalDay).type.as(Int32)

      time_tokens = tokens.last(tokens.size - 2)
      year = self.now.year
      month = self.now.month
      if context == PointerDir::Future
        # raise NotImplementedError.new("badness")
        # ???#
        if self.now.day > day
          month += 1
        else
          month
        end
      end

      return nil if Date.month_overflow?(year, month, day)

      begin
        if time_tokens.empty?
          start_time = Time.local(year, month, day)
          end_time = time_with_rollover(year, month, day + 1)
          SecSpan.new(start_time, end_time)
        else
          day_start = Time.local(year, month, day)
          day_or_time(day_start, time_tokens, **options)
        end
      rescue ArgumentError
        nil
      end
    end

    # Handle RepeaterDayName RepeaterMonthName ScalarDay
    def handle_rdn_rmn_sd(tokens, **options)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[2].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      time_tokens = tokens.last(tokens.size - 3)
      year = self.now.year

      return nil if Date.month_overflow?(year, month.index, day)

      begin
        if time_tokens.empty?
          start_time = Time.local(year, month.index, day)
          end_time = time_with_rollover(year, month.index, day + 1)
          SecSpan.new(start_time, end_time)
        else
          day_start = Time.local(year, month.index, day)
          day_or_time(day_start, time_tokens, **options)
        end
      rescue ArgumentError
        nil
      end
    end

    # Handle RepeaterDayName RepeaterMonthName ScalarDay ScalarYear
    def handle_rdn_rmn_sd_sy(tokens, **options)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName)
      day = tokens[2].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      year = tokens[3].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)

      return nil if Date.month_overflow?(year, month.index, day)

      begin
        start_time = Time.local(year, month.index, day)
        end_time = time_with_rollover(year, month.index, day + 1)
        SecSpan.new(start_time, end_time)
      rescue ArgumentError
        nil
      end
    end

    def handle_sm_rmn_sy(tokens, **options)
      day = tokens[0].get_tag(ScalarDay).as(ScalarDay).type.as(Int32)
      month = tokens[1].get_tag(RepeaterMonthName).as(RepeaterMonthName).index
      year = tokens[2].get_tag(ScalarYear).as(ScalarYear).type.as(Int32)
      if tokens.size > 3
        time = get_anchor([tokens.last], **options).as(SecSpan).begin
        h, m, s = time.hour, time.minute, time.second
        time = Time.local(year, month, day, h, m, s)
        end_time = Time.local(year, month, day + 1, h, m, s)
      else
        time = Time.local(year, month, day)
        day += 1 unless day >= 31
        end_time = Time.local(year, month, day)
      end
      SecSpan.new(time, end_time)
    end

    # anchors

    # Handle repeaters
    def handle_r(tokens, **options)
      dd_tokens = Handlers.dealias_and_disambiguate_times(tokens, **options)
      get_anchor(dd_tokens, **options)
    end

    # Handle repeater/grabber/repeater
    def handle_r_g_r(tokens, **options)
      new_tokens = [tokens[1], tokens[0], tokens[2]]
      handle_r(new_tokens, **options)
    end

    # arrows

    # Handle scalar/repeater/pointer helper
    def subhandle_srp(tokens, span : SecSpan, **options) : SecSpan?
      distance = tokens[0].get_tag(Scalar).as(Scalar).type.as(Int32)
      repeater = tokens[1].get_tag(Repeater).as(Repeater)
      pointer = tokens[2].get_tag(Pointer).as(Pointer).dir

      repeater.offset(span, distance, pointer) if repeater.responds_to?(:offset)
    end

    # Handle scalar/repeater/pointer
    def handle_s_r_p(tokens, **options)
      span = SecSpan.new(self.now, self.now + 1.second)
      subhandle_srp(tokens, span, **options)
    end

    # Handle pointer/scalar/repeater
    def handle_p_s_r(tokens, **options)
      span = SecSpan.new(self.now, self.now + 1.second)
      new_tokens = [tokens[1], tokens[2], tokens[0]]
      subhandle_srp(new_tokens, span, **options)
    end

    # Handle scalar/repeater/pointer/anchor
    def handle_s_r_p_a(tokens, **options)
      anchor_span = get_anchor(tokens[3..tokens.size - 1], **options)
      subhandle_srp(tokens, anchor_span.as(SecSpan), **options)
    end

    # Handle repeater/scalar/repeater/pointer
    def handle_rmn_s_r_p(tokens, **options)
      handle_s_r_p_a(tokens[1..3] + tokens[0..0], **options)
    end

    def handle_s_r_a_s_r_p_a(tokens, **options)
      anchor_span = get_anchor(tokens[4..tokens.size - 1], **options)
      # anchor_tokens = tokens[4..tokens.size - 1]
      # anchor_span = if anchor_tokens.size > 1
      #                get_anchor(anchor_tokens, options)
      #              else
      #                SecSpan.new(self.now, self.now + 1.second)
      #              end

      span = subhandle_srp(tokens[0..1] + tokens[4..6], anchor_span.as(SecSpan), **options)
      subhandle_srp(tokens[2..3] + tokens[4..6], span.as(SecSpan), **options)
    end

    # =======
    # Narrows
    # =======

    # Handle ordinal repeaters
    def subhandle_orr(tokens, outer_span, **options)
      ordinal = tokens[0].get_tag(Ordinal).as(Ordinal).type
      repeater = tokens[1].get_tag(Repeater).as(Repeater)
      repeater.start = outer_span.as(SecSpan).begin - 1.second

      span = nil

      ordinal.as(Int32).times do
        span = repeater.next(PointerDir::Future).as(SecSpan)
        if span.begin >= outer_span.as(SecSpan).end
          raise Cronic::InvalidParseError.new("Cannot find Date/Time in span #{outer_span.inspect}")
        end
      end

      span
    end

    # Handle ordinal/repeater/separator/repeater
    def handle_o_r_s_r(tokens, **options)
      outer_span = get_anchor([tokens[3]], **options)
      subhandle_orr(tokens[0..1], outer_span, **options)
    end

    # Handle ordinal/repeater/grabber/repeater
    def handle_o_r_g_r(tokens, **options)
      outer_span = get_anchor(tokens[2..3], **options)
      subhandle_orr(tokens[0..1], outer_span, **options)
    end

    # support methods

    def day_or_time(day_start : Time, time_tokens, context : PointerDir = PointerDir::Future, **options)
      outer_span = SecSpan.new(day_start, day_start + Time::Span.new(hours: 24))

      unless time_tokens.empty?
        self.now = outer_span.begin
        get_anchor(Handlers.dealias_and_disambiguate_times(time_tokens, **options), context: context)
      else
        outer_span
      end
    end

    def get_anchor(tokens, context = PointerDir::None, **options)
      grabber = Grabber.new(GrabberEnum::This)
      pointer = PointerDir::Future
      repeaters = get_repeaters(tokens)

      repeaters.size.times { tokens.pop }

      if tokens[0]? && tokens[0].get_tag(Grabber)
        grabber = tokens.shift.get_tag(Grabber).as(Grabber)
      end

      head = repeaters.shift
      head.start = self.now

      case grabber.grab
      in GrabberEnum::Last
        outer_span = head.next(PointerDir::Past)
      in GrabberEnum::This
        if (context != PointerDir::Past) && (repeaters.size > 0)
          outer_span = head.this(PointerDir::None)
        else
          outer_span = head.this(context)
        end
      in GrabberEnum::Next
        outer_span = head.next(PointerDir::Future)
      end

      raise Exception.new("Invalid nil for outer_span") if outer_span.nil?

      if Cronic.debug
        puts "Handler-class: #{head.class}"
        puts "--#{outer_span}"
      end

      find_within(repeaters, outer_span, pointer)
    end

    def get_repeaters(tokens)
      repeaters = tokens.map { |token| token.get_tag(Repeater) }
      repeaters = repeaters.compact.map { |rpt| rpt.as(Repeater) }
      repeaters.sort.reverse
    end

    # Recursively finds repeaters within other repeaters.
    # Returns a SecSpan representing the innermost time span
    # or nil if no repeater union could be found
    def find_within(tags, span : SecSpan, pointer : PointerDir) : SecSpan?
      puts "--#{span}" if Cronic.debug
      return span if tags.empty?

      head = tags.shift
      head.start = (pointer == PointerDir::Future) ? span.begin : span.end
      h = head.this(PointerDir::None).as(SecSpan)

      if span.includes?(h.begin) || span.includes?(h.end)
        find_within(tags, h, pointer)
      end
    end

    def find_within(tags, span : Nil, pointer : PointerDir)
      return nil
    end

    def time_with_rollover(year, month, day)
      if Date.month_overflow?(year, month, day)
        if month == 12
          Time.local(year + 1, 1, 1)
        else
          Time.local(year, month + 1, 1)
        end
      else
        Time.local(year, month, day)
      end
    end

    def self.dealias_and_disambiguate_times(tokens, ambiguous_time_range : Int32? = 6, **options)
      # handle aliases of am/pm
      # 5:00 in the morning -> 5:00 am
      # 7:00 in the evening -> 7:00 pm

      day_portion_index = nil
      tokens.each_with_index do |t, i|
        if t.get_tag(RepeaterDayPortion)
          day_portion_index = i
          break
        end
      end

      time_index = nil
      tokens.each_with_index do |t, i|
        if t.get_tag(RepeaterTime)
          time_index = i
          break
        end
      end

      if day_portion_index && time_index
        t1 = tokens[day_portion_index]
        t1tag = t1.get_tag(RepeaterDayPortion).as(Tag)

        case t1tag.type
        when :morning
          puts "--morning->am" if Cronic.debug
          t1.untag(RepeaterDayPortion)
          t1.tag(RepeaterDayPortion.new(:am))
        when :afternoon, :evening, :night
          puts "--#{t1tag.type}->pm" if Cronic.debug
          t1.untag(RepeaterDayPortion)
          t1.tag(RepeaterDayPortion.new(:pm))
        end
      end

      # handle ambiguous times if :ambiguous_time_range is specified
      if ambiguous_time_range.is_a?(Int32)
        ambiguous_tokens = [] of Token

        tokens.each_with_index do |token, i|
          ambiguous_tokens << token
          next_token = tokens[i + 1]?

          if token.get_tag(RepeaterTime) && token.get_tag(RepeaterTime).as(RepeaterTime).tagtype.ambiguous? && (!next_token || !next_token.get_tag(RepeaterDayPortion))
            distoken = Token.new("disambiguator")

            distoken.tag(RepeaterDayPortion.new(ambiguous_time_range))
            ambiguous_tokens << distoken
          end
        end

        tokens = ambiguous_tokens
      end

      tokens
    end
  end
end
