require "spec"
require "../src/cronic"

include Cronic

def test_maybetime
  {Or.maybe(RepeaterTime), Or.maybe(RepeaterDayPortion)}
end

describe Cronic::Handlers do
  it "matches a single item sequence" do
    seq = Sequence.seq(Repeater)

    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("afternoon")
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    SeqMatcher.match(seq, tokens).should eq false
  end

  it "matches a item, maybe-item sequence" do
    seq = Sequence.seq(Repeater, Or.maybe(Repeater))

    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("afternoon")
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("afternoon")
    tokens[2].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    SeqMatcher.match(seq, tokens).should eq false
  end

  pending "matches a rpt-maybetime sequence" do
    # TODO current spec is repeater, maybe(time), maybe(dayportion)
    # but we want it to be:
    #    repeater, maybe( seq(time, maybe(dayportion) ))
    # but for now we dont have an implementation that supports that.
    seq = Sequence.seq(Repeater, *test_maybetime)

    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("afternoon")
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    SeqMatcher.match(seq, tokens).should eq false
  end

  it "matches a rmn-sd-maybetime sequence" do
    seq = Sequence.seq(RepeaterMonthName, ScalarDay, *test_maybetime)

    tokens = [Cronic::Token.new("may")]
    tokens[0].tag(Cronic::RepeaterMonthName.new(:may))
    SeqMatcher.match(seq, tokens).should eq false

    tokens << Cronic::Token.new("27")
    tokens[1].tag(Cronic::ScalarDay.new(27))
    SeqMatcher.match(seq, tokens).should eq true
  end

  it "matches a rpt-maybetime sequence" do
    seq = Sequence.seq(Repeater, *test_maybetime)

    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("5:00")
    tokens[1].tag(Cronic::RepeaterTime.new("5:00"))
    SeqMatcher.match(seq, tokens).should eq true

    tokens << Cronic::Token.new("pm")
    tokens[2].tag(Cronic::RepeaterDayPortion.new(:pm))
    SeqMatcher.match(seq, tokens).should eq true
  end

  it "matches a three item sequence" do
    seq = Sequence.new([Scalar, Repeater, Cronic::Pointer])
    tokens = [Cronic::Token.new("3"), Cronic::Token.new("years"), Cronic::Token.new("past")]
    tokens[0].tag(Cronic::Scalar.new(3))
    tokens[1].tag(Cronic::RepeaterYear.new(:year))
    tokens[2].tag(Cronic::Pointer.new(Cronic::PointerDir::Past))
    SeqMatcher.match(seq, tokens).should eq true
  end

  it "matches or+item sequence" do
    seq = Sequence.new([Or.or(SeparatorOn, SeparatorAt), Scalar])

    tokens = [Cronic::Token.new("at"), Cronic::Token.new("14")]
    tokens[0].tag(Cronic::SeparatorAt.new("at"))
    tokens[1].tag(Cronic::Scalar.new(14))
    SeqMatcher.match(seq, tokens).should eq true

    tokens = [Cronic::Token.new("on"), Cronic::Token.new("15")]
    tokens[0].tag(Cronic::SeparatorOn.new("on"))
    tokens[1].tag(Cronic::Scalar.new(15))
    SeqMatcher.match(seq, tokens).should eq true
  end
end
