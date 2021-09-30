require "./spec_helper"

describe Cronic do
  it "pre normalizes a time" do
    Cronic::Parser.new.pre_normalize("12.55 pm").should eq Cronic::Parser.new.pre_normalize("12:55 pm")
  end

  it "pre normalizes a numerized string" do
    string = "two and a half years"
    Cronic::Parser.new.pre_normalize(string).should eq NumberParser.parse(string)
  end

  it "can post normalize am/pm aliases" do
    tokens = [Cronic::Token.new("5:00"), Cronic::Token.new("morning")]
    tokens[0].tag(Cronic::RepeaterTime.new("5:00"))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:morning))
    tokens[1].tags[0].type.should eq :morning
    tokens = Cronic::Handlers.dealias_and_disambiguate_times(tokens)
    tokens[1].tags[0].type.should eq :am
    tokens.size.should eq 2
    tokens = [Cronic::Token.new("friday"), Cronic::Token.new("morning")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:morning))
    tokens[1].tags[0].type.should eq :morning
    tokens = Cronic::Handlers.dealias_and_disambiguate_times(tokens)
    tokens[1].tags[0].type.should eq :morning
    tokens.size.should eq 2
  end

  it "guesses within a Timespan" do
    span = Cronic::Timespan.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 8, 16, 12)
    span = Cronic::Timespan.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0, 0, 1))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 8, 16, 12)
    span = Cronic::Timespan.new(Time.local(2006, 11, 1), Time.local(2006, 12, 1))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 11, 16)
  end

  describe "construct" do
    it "constructs like Time.local" do
      Cronic.construct(2006, 1, 2, 0, 0, 0).should eq Time.local(2006, 1, 2, 0, 0, 0)
      Cronic.construct(2006, 1, 2, 3, 0, 0).should eq Time.local(2006, 1, 2, 3, 0, 0)
      Cronic.construct(2006, 1, 2, 3, 4, 0).should eq Time.local(2006, 1, 2, 3, 4, 0)
      Cronic.construct(2006, 1, 2, 3, 4, 5).should eq Time.local(2006, 1, 2, 3, 4, 5)
    end
    it "supports second overflow" do
      Cronic.construct(2006, 1, 1, 0, 0, 90).should eq Time.local(2006, 1, 1, 0, 1, 30)
      Cronic.construct(2006, 1, 1, 0, 0, 300).should eq Time.local(2006, 1, 1, 0, 5, 0)
    end
    it "supports minute overflow" do
      Cronic.construct(2006, 1, 1, 0, 90).should eq Time.local(2006, 1, 1, 1, 30)
      Cronic.construct(2006, 1, 1, 0, 300).should eq Time.local(2006, 1, 1, 5)
    end
    it "supports hour overflow" do
      Cronic.construct(2006, 1, 1, 36).should eq Time.local(2006, 1, 2, 12)
      Cronic.construct(2006, 1, 1, 144).should eq Time.local(2006, 1, 7)
    end
    it "supports day overflow" do
      Cronic.construct(2006, 1, 32).should eq Time.local(2006, 2, 1)
      Cronic.construct(2006, 2, 33).should eq Time.local(2006, 3, 5)
      Cronic.construct(2004, 2, 33).should eq Time.local(2004, 3, 4)
      Cronic.construct(2000, 2, 33).should eq Time.local(2000, 3, 4)
      expect_raises(Exception) { Cronic.construct(2006, 1, 57) }
    end
    it "supports month overflow" do
      Cronic.construct(2005, 13).should eq Time.local(2006, 1, 1)
      Cronic.construct(2000, 72).should eq Time.local(2005, 12, 1)
    end
  end

  it "can parse given all valid keyword args" do
    Cronic.parse("now",
      context: Cronic::PointerDir::Future,
      now: now_time,
      hours24: nil,
      week_start: Time::DayOfWeek::Sunday,
      ambiguous_time_range: 6,
      endian_precedence: [Cronic::DateEndian::MonthDay, Cronic::DateEndian::DayMonth],
      ambiguous_year_future_bias: 50)
  end
end
