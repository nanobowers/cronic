require "./spec_helper"

describe Cronic do
  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("pre normalize") do
    Cronic::Parser.new.pre_normalize("12.55 pm").should eq Cronic::Parser.new.pre_normalize("12:55 pm")
  end
  it("pre normalize numerized string") do
    string = "two and a half years"
    Cronic::Parser.new.pre_normalize(string).should eq Numerizer.numerize(string)
  end
  it("post normalize am pm aliases") do
    empty = {} of String => String
    tokens = [Cronic::Token.new("5:00"), Cronic::Token.new("morning")]
    tokens[0].tag(Cronic::RepeaterTime.new("5:00"))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:morning))
    tokens[1].tags[0].type.should eq :morning
    tokens = Cronic::Handlers.dealias_and_disambiguate_times(tokens, emptyh)
    tokens[1].tags[0].type.should eq :am
    tokens.size.should eq 2
    tokens = [Cronic::Token.new("friday"), Cronic::Token.new("morning")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:morning))
    tokens[1].tags[0].type.should eq :morning
    tokens = Cronic::Handlers.dealias_and_disambiguate_times(tokens, emptyh)
    tokens[1].tags[0].type.should eq :morning
    tokens.size.should eq 2
  end
  it("guess") do
    span = Cronic::Span.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 8, 16, 12)
    span = Cronic::Span.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0, 0, 1))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 8, 16, 12)
    span = Cronic::Span.new(Time.local(2006, 11), Time.local(2006, 12))
    Cronic::Parser.new.guess(span).should eq Time.local(2006, 11, 16)
  end
  it("endian definitions") do
    endians = [Cronic::Handler.new([:scalar_month, [:separator_slash, :separator_dash], :scalar_day, [:separator_slash, :separator_dash], :scalar_year, :separator_at?, "time?"], :handle_sm_sd_sy), Cronic::Handler.new([:scalar_month, [:separator_slash, :separator_dash], :scalar_day, :separator_at?, "time?"], :handle_sm_sd), Cronic::Handler.new([:scalar_day, [:separator_slash, :separator_dash], :scalar_month, :separator_at?, "time?"], :handle_sd_sm), Cronic::Handler.new([:scalar_day, [:separator_slash, :separator_dash], :scalar_month, [:separator_slash, :separator_dash], :scalar_year, :separator_at?, "time?"], :handle_sd_sm_sy), Cronic::Handler.new([:scalar_day, :repeater_month_name, :scalar_year, :separator_at?, "time?"], :handle_sd_rmn_sy)]
    Cronic::SpanDictionary.new.definitions[:endian].should eq endians
    defs = Cronic::SpanDictionary.new(endian_precedence: :little).definitions
    defs[:endian].should eq endians.reverse
    defs = Cronic::SpanDictionary.new(endian_precedence: ([:little, :middle])).definitions
    defs[:endian].should eq endians.reverse
    expect do
      Cronic::SpanDictionary.new(endian_precedence: :invalid).definitions
    end.to(raise_error(ArgumentError))
  end
#  it("debug") do
#    begin
#      (require("stringio")
#      $stdout = StringIO.new
#      Cronic.debug = true
#      Cronic.parse("now")
#      $stdout.string.include?("this(grabber-this)").should eq true)
#    ensure
#      ($stdout = STDOUT
#      Cronic.debug = false)
#    end
#  end
  it("normal") do
    Cronic.construct(2006, 1, 2, 0, 0, 0).should eq Time.local(2006, 1, 2, 0, 0, 0)
    Cronic.construct(2006, 1, 2, 3, 0, 0).should eq Time.local(2006, 1, 2, 3, 0, 0)
    Cronic.construct(2006, 1, 2, 3, 4, 0).should eq Time.local(2006, 1, 2, 3, 4, 0)
    Cronic.construct(2006, 1, 2, 3, 4, 5).should eq Time.local(2006, 1, 2, 3, 4, 5)
  end
  it("second overflow") do
    Cronic.construct(2006, 1, 1, 0, 0, 90).should eq Time.local(2006, 1, 1, 0, 1, 30)
    Cronic.construct(2006, 1, 1, 0, 0, 300).should eq Time.local(2006, 1, 1, 0, 5, 0)
  end
  it("minute overflow") do
    Cronic.construct(2006, 1, 1, 0, 90).should eq Time.local(2006, 1, 1, 1, 30)
    Cronic.construct(2006, 1, 1, 0, 300).should eq Time.local(2006, 1, 1, 5)
  end
  it("hour overflow") do
    Cronic.construct(2006, 1, 1, 36).should eq Time.local(2006, 1, 2, 12)
    Cronic.construct(2006, 1, 1, 144).should eq Time.local(2006, 1, 7)
  end
  it("day overflow") do
    Cronic.construct(2006, 1, 32).should eq Time.local(2006, 2, 1)
    Cronic.construct(2006, 2, 33).should eq Time.local(2006, 3, 5)
    Cronic.construct(2004, 2, 33).should eq Time.local(2004, 3, 4)
    Cronic.construct(2000, 2, 33).should eq Time.local(2000, 3, 4)
    expect { Cronic.construct(2006, 1, 57) }.to(raise_error(RuntimeError))
  end
  it("month overflow") do
    Cronic.construct(2005, 13).should eq Time.local(2006, 1)
    Cronic.construct(2000, 72).should eq Time.local(2005, 12)
  end
  it("time") do
    org = Cronic.time_class
    begin
      (Cronic.time_class = ::Time
      Cronic.construct(2013, 8, 27, 20, 30, 40, "+05:30").should eq ::Time.new(2013, 8, 27, 20, 30, 40, "+05:30")
      Cronic.construct(2013, 8, 27, 20, 30, 40, -28800).should eq ::Time.new(2013, 8, 27, 20, 30, 40, "-08:00"))
    ensure
      Cronic.time_class = org
    end
  end
  it("date") do
    org = Cronic.time_class
    begin
      (Cronic.time_class = ::Date
      Cronic.construct(2013, 8, 27).should eq Date.new(2013, 8, 27))
    ensure
      Cronic.time_class = org
    end
  end
  it("datetime") do
    org = Cronic.time_class
    begin
      (Cronic.time_class = ::DateTime
      Cronic.construct(2013, 8, 27, 20, 30, 40, "+05:30").should eq DateTime.new(2013, 8, 27, 20, 30, 40, "+05:30")
      Cronic.construct(2013, 8, 27, 20, 30, 40, -28800).should eq DateTime.new(2013, 8, 27, 20, 30, 40, "-08:00"))
    ensure
      Cronic.time_class = org
    end
  end
  it("valid options") do
    Cronic.parse("now", context: :future, now: nil, hours24: nil, week_start: :sunday, guess: true, ambiguous_time_range: 6, endian_precedence: ([:middle, :little]), ambiguous_year_future_bias: 50).should_not be nil
  end
  it("invalid options") do
    expect { Cronic.parse("now", foo: "boo") }.to(raise_error(ArgumentError))
    expect { Cronic.parse("now", time_class: (Time)) }.to(raise_error(ArgumentError))
  end

end
