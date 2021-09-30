module Cronic
  alias SeqType = Array(Tag.class) |
                  Array(Tag.class | Or) |
                  Array(SeparatorAt.class) |
                  Array(Separator.class) |
                  Array(Scalar.class | Or) |
                  Array(Repeater.class | Or) |
                  Array(Repeater.class) |
                  Array(OrdinalDay.class)

  alias OrSeqType = Array(Tag.class) |
                    Array(Grabber.class) |
                    Array(Repeater.class) |
                    Array(RepeaterDayPortion.class) |
                    Array(RepeaterTime.class) |
                    Array(Scalar.class) |
                    Array(Separator.class) |
                    Array(SeparatorAnd.class) |
                    Array(SeparatorSlash.class) |
                    Array(SeparatorDash.class) |
                    Array(SeparatorAt.class) |
                    Array(SeparatorOn.class) |
                    Array(TimeZone.class) |
                    Array(Or | Tag.class) |
                    Array(Or | Scalar.class) |
                    Array(Or | Repeater.class) |
                    Array(Or | RepeaterTime.class) |
                    Array(Tag.class | Or)

  # Holds either an Or / maybe clause for use with matching.  If the maybe flag is set, then none of the items are required to match.
  class Or
    getter :items
    getter? :maybe

    def initialize(@items : OrSeqType, @maybe = false)
    end

    # Factory method to make an Or from one..N args
    def self.or(*items)
      self.new(items.to_a, maybe: false)
    end

    # Factory method to make an Or/Maybe from one..N args
    def self.maybe(*items)
      self.new(items.to_a, maybe: true)
    end
  end

  # A matching sequence.  The sequence is an Array of class names or `Or` / maybe clauses.  Used in conjunction with `SeqMatcher`
  class Sequence
    getter :items

    def initialize(@items : SeqType)
    end

    # Factory method to make a Sequence
    def self.seq(*items)
      self.new(items.to_a)
    end

    # Returns true if the Sequence is empty
    def empty?
      @items.empty?
    end

    # Get first element of the sequence
    def first
      @items[0]
    end

    def rest
      @items[1..]
    end

    def [](arg)
      @items[arg]
    end
  end

  # SpanDefinitions subclasses return an Array of NamedTuples containing a match sequence and a Proc that calls a token handler (see handler.cr)
  class SpanDefinitions
    include Handlers
    property :now

    def initialize(@now : Time)
    end

    # Shortcut for single-term Or with maybe
    def maybe(item)
      Or.new([item], maybe: true)
    end

    # Shortcut for double-term Or
    def or(item, item2)
      Or.new([item, item2], maybe: false)
    end

    # Shortcut for double-term Or with maybe
    def ormaybe(item, item2)
      Or.new([item, item2], maybe: true)
    end

    # Shortcut for common date separators
    def slashdash
      or(SeparatorSlash, SeparatorDash)
    end

    # Shortcut for a time and day-portion
    # TODO: Actually should be: `ormaybe(RepeaterTime, seq(RepeaterTime, RepeaterDayPortion))`, but this is not supported by our matching engine.
    def maybetime
      [maybe(RepeaterTime), maybe(RepeaterDayPortion)]
    end

    # Shortcut for shared anchor #1
    def anchor1
      [maybe(SeparatorOn), maybe(Grabber), Repeater, maybe(SeparatorAt), maybe(Repeater), maybe(Repeater)]
    end

    # Shortcut for shared anchor #2
    def anchor2
      [maybe(Grabber), Repeater, Repeater, maybe(Separator), maybe(Repeater), maybe(Repeater)]
    end

    # Shortcut for shared anchor #3
    def anchor3
      [Repeater, Grabber, Repeater]
    end
  end

  # Matchers and handlers for a variety of date formats
  class DateDefinitions < SpanDefinitions
    def definitions(**opts)
      [
        {match: Sequence.new([ScalarDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sd_rmn_sy(toks, **opts) }},

        {match: Sequence.new([ScalarYear, SeparatorDash, ScalarMonth, SeparatorDash, ScalarDay, RepeaterTime, TimeZone]), proc: ->(toks : Array(Token)) { handle_rfc3339(toks, **opts) }},
        {match: Sequence.new([ScalarYear, SeparatorDash, ScalarMonth, SeparatorDash, ScalarDay, RepeaterTime]), proc: ->(toks : Array(Token)) { handle_rfc3339_no_tz(toks, **opts) }},

        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, RepeaterTime, ormaybe(SeparatorSlash, SeparatorDash), TimeZone, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_sd_t_tz_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_sd_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_sd(toks, **opts) }},

        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_od_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_od(toks, **opts) }},

        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_sd(toks, **opts) }},
        {match: Sequence.new([RepeaterDayName, RepeaterMonthName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rdn_rmn_od(toks, **opts) }},
        {match: Sequence.new([RepeaterDayName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rdn_od(toks, **opts) }},
        {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, ScalarDay, RepeaterTime, TimeZone]), proc: ->(toks : Array(Token)) { handle_generic(toks, **opts) }},
        {match: Sequence.new([OrdinalDay]), proc: ->(toks : Array(Token)) { handle_ordday(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, ScalarDay, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rmn_sd_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, OrdinalDay, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rmn_od_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, ScalarDay, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rmn_sd_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, OrdinalDay, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rmn_od_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, ormaybe(SeparatorSlash, SeparatorDash), ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rmn_sd(toks, **opts) }},

        {match: Sequence.new([RepeaterTime, maybe(RepeaterDayPortion), maybe(SeparatorOn), RepeaterMonthName, ScalarDay]), proc: ->(toks : Array(Token)) { handle_rmn_sd_on(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, OrdinalDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_rmn_od(toks, **opts) }},
        {match: Sequence.new([OrdinalDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_od_rmn_sy(toks, **opts) }},
        {match: Sequence.new([OrdinalDay, RepeaterMonthName, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_od_rmn(toks, **opts) }},
        {match: Sequence.new([OrdinalDay, maybe(Grabber), RepeaterMonth, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_od_rm(toks, **opts) }},

        {match: Sequence.new([ScalarYear, RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)) { handle_sy_rmn_od(toks, **opts) }},
        {match: Sequence.new([RepeaterTime, maybe(RepeaterDayPortion), maybe(SeparatorOn), RepeaterMonthName, OrdinalDay]), proc: ->(toks : Array(Token)) { handle_rmn_od_on(toks, **opts) }},
        {match: Sequence.new([RepeaterMonthName, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rmn_sy(toks, **opts) }},
        {match: Sequence.new([RepeaterQuarterName, ScalarYear]), proc: ->(toks : Array(Token)) { handle_rqn_sy(toks, **opts) }},
        {match: Sequence.new([ScalarYear, RepeaterQuarterName]), proc: ->(toks : Array(Token)) { handle_sy_rqn(toks, **opts) }},
        {match: Sequence.new([ScalarDay, RepeaterMonthName, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sd_rmn_sy(toks, **opts) }},
        {match: Sequence.new([ScalarDay, ormaybe(SeparatorSlash, SeparatorDash), RepeaterMonthName, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sd_rmn(toks, **opts) }},
        {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sy_sm_sd(toks, **opts) }},
        {match: Sequence.new([ScalarYear, slashdash, ScalarMonth]), proc: ->(toks : Array(Token)) { handle_sy_sm(toks, **opts) }},
        {match: Sequence.new([ScalarMonth, slashdash, ScalarYear]), proc: ->(toks : Array(Token)) { handle_sm_sy(toks, **opts) }},
        {match: Sequence.new([ScalarDay, slashdash, RepeaterMonthName, slashdash, ScalarYear, maybe(RepeaterTime)]), proc: ->(toks : Array(Token)) { handle_sm_rmn_sy(toks, **opts) }},
        {match: Sequence.new([ScalarYear, slashdash, ScalarMonth, slashdash, maybe(Scalar), TimeZone]), proc: ->(toks : Array(Token)) { handle_generic(toks, **opts) }},
      ]
    end
  end

  # Matchers and handlers for a variety of bare "anchors"
  class AnchorDefinitions < SpanDefinitions
    def definitions(**opts)
      [
        {match: Sequence.new(anchor1), proc: ->(toks : Array(Token)) { handle_r(toks, **opts) }},
        {match: Sequence.new(anchor2), proc: ->(toks : Array(Token)) { handle_r(toks, **opts) }},
        {match: Sequence.new(anchor3), proc: ->(toks : Array(Token)) { handle_r_g_r(toks, **opts) }},
      ]
    end
  end

  # Matchers and handlers for a variety of complex combos of `Scalar`, `Repeater` and `Cronic::Pointer`
  class ArrowDefinitions < SpanDefinitions
    def definitions(**opts)
      sr_and_srp_at = [Scalar, Repeater, maybe(SeparatorAnd), Scalar, Repeater, Pointer, maybe(SeparatorAt)]
      [
        {match: Sequence.new([RepeaterMonthName, Scalar, Repeater, Pointer]), proc: ->(toks : Array(Token)) { handle_rmn_s_r_p(toks, **opts) }},
        {match: Sequence.new([Scalar, Repeater, Pointer]), proc: ->(toks : Array(Token)) { handle_s_r_p(toks, **opts) }},
        {match: Sequence.new(sr_and_srp_at + anchor1), proc: ->(toks : Array(Token)) { handle_s_r_a_s_r_p_a(toks, **opts) }},
        {match: Sequence.new(sr_and_srp_at + anchor2), proc: ->(toks : Array(Token)) { handle_s_r_a_s_r_p_a(toks, **opts) }},
        {match: Sequence.new(sr_and_srp_at + anchor3), proc: ->(toks : Array(Token)) { handle_s_r_a_s_r_p_a(toks, **opts) }},

        {match: Sequence.new([Pointer, Scalar, Repeater]), proc: ->(toks : Array(Token)) { handle_p_s_r(toks, **opts) }},

        {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor1]), proc: ->(toks : Array(Token)) { handle_s_r_p_a(toks, **opts) }},
        {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor2]), proc: ->(toks : Array(Token)) { handle_s_r_p_a(toks, **opts) }},
        {match: Sequence.new([Scalar, Repeater, Pointer, maybe(SeparatorAt), *anchor3]), proc: ->(toks : Array(Token)) { handle_s_r_p_a(toks, **opts) }},

      ]
    end
  end

  # Matchers and handlers for a things that narrow a time-span
  class NarrowDefinitions < SpanDefinitions
    def definitions(**opts)
      [
        {match: Sequence.new([Ordinal, Repeater, SeparatorIn, Repeater]), proc: ->(toks : Array(Token)) { handle_o_r_s_r(toks, **opts) }},
        {match: Sequence.new([Ordinal, Repeater, Grabber, Repeater]), proc: ->(toks : Array(Token)) { handle_o_r_g_r(toks, **opts) }},
      ]
    end
  end

  # Matchers and handlers for ScalarMonth/ScalarDay cases that can have
  # their endian precedence changed based on user specification.
  class EndianDefinitions < SpanDefinitions
    def month_day(**opts)
      [
        {match: Sequence.new([ScalarMonth, slashdash, ScalarDay, slashdash, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sm_sd_sy(toks, **opts) }},
        {match: Sequence.new([ScalarMonth, slashdash, ScalarDay, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sm_sd(toks, **opts) }},
      ]
    end

    def day_month(**opts)
      [
        {match: Sequence.new([ScalarDay, slashdash, ScalarMonth, slashdash, ScalarYear, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sd_sm_sy(toks, **opts) }},
        {match: Sequence.new([ScalarDay, slashdash, ScalarMonth, maybe(SeparatorAt), *maybetime]), proc: ->(toks : Array(Token)) { handle_sd_sm(toks, **opts) }},
      ]
    end

    def definitions(endian_precedence : Array(DateEndian), **opts)
      defs = [] of NamedTuple(match: Sequence, proc: Proc(Array(Token), Timespan?))

      endian_precedence.each do |endian|
        case endian
        in DateEndian::MonthDay
          defs += month_day(**opts)
        in DateEndian::DayMonth
          defs += day_month(**opts)
        end
      end
      defs
    end
  end
end
