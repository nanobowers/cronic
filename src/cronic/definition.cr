module Cronic
  alias SeqType = Array(Tag.class) |
                  Array(Tag.class | Or) |
                  Array(SeparatorAt.class) |
                  Array(Separator.class) |
                  Array(Scalar.class | Or) |
                  Array(Repeater.class | Or) |
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
                    Array(Tag.class | Or)

  class Or
    getter :items
    getter? :maybe

    def initialize(@items : OrSeqType, @maybe = false)
    end
  end

  class Sequence
    getter :items

    def initialize(@items : SeqType)
    end

    def empty?
      @items.empty?
    end

    def first
      @items[0]
    end

    def [](arg)
      @items[arg]
    end
  end

  # SpanDefinitions subclasses return definitions constructed by Handler instances (see handler.rb)
  # SpanDefinitions subclasses follow a <Type> + Definitions naming pattern

  class SpanDefinitions # < Definitions

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

    # common date separators
    def slashdash
      or(SeparatorSlash, SeparatorDash)
    end

    def maybetime
      [maybe(RepeaterTime), maybe(RepeaterDayPortion)]
    end

    # shared anchors
    def anchor1
      [maybe(SeparatorOn), maybe(Grabber), Repeater, maybe(SeparatorAt), maybe(Repeater), maybe(Repeater)]
    end

    def anchor2
      [maybe(Grabber), Repeater, Repeater, maybe(Separator), maybe(Repeater), maybe(Repeater)]
    end

    def anchor3
      [Repeater, Grabber, Repeater]
    end
  end

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

  class AnchorDefinitions < SpanDefinitions
    def definitions(**opts)
      [
        {match: Sequence.new(anchor1), proc: ->(toks : Array(Token)) { handle_r(toks, **opts) }},
        {match: Sequence.new(anchor2), proc: ->(toks : Array(Token)) { handle_r(toks, **opts) }},
        {match: Sequence.new(anchor3), proc: ->(toks : Array(Token)) { handle_r_g_r(toks, **opts) }},
      ]
    end
  end

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

  class NarrowDefinitions < SpanDefinitions
    def definitions(**opts)
      [
        {match: Sequence.new([Ordinal, Repeater, SeparatorIn, Repeater]), proc: ->(toks : Array(Token)) { handle_o_r_s_r(toks, **opts) }},
        {match: Sequence.new([Ordinal, Repeater, Grabber, Repeater]), proc: ->(toks : Array(Token)) { handle_o_r_g_r(toks, **opts) }},
      ]
    end
  end

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
      defs = [] of NamedTuple(match: Sequence, proc: Proc(Array(Token), SecSpan?))

      endian_precedence.each do |endian|
        case endian
        in DateEndian::MonthDay
          defs += month_day(**opts)
        in DateEndian::DayMonth
          defs += day_month(**opts)
        end
      end
      return defs
    end
  end
end
