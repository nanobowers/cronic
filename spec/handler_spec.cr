require "spec"
require "../src/cronic"


#def definitions
#  @definitions ||= 
#end

#definitions : Hash(String, Array(Cronic::Handler))
#Spec.before_each do
#  definitions = Cronic::SpanDictionary.new.definitions
#end

describe Cronic::Handler do

  
  it("handler class 1") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["repeater"], "handler")
    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("afternoon"))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    handler.match(tokens, definitions).should_not be_truthy
  end
  it("handler class 2") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["repeater", "repeater?"], "handler")
    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("afternoon"))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("afternoon"))
    tokens[2].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    handler.match(tokens, definitions).should_not be_truthy
  end
  it("handler class 3") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["repeater", "time?"], "handler")
    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("afternoon"))
    tokens[1].tag(Cronic::RepeaterDayPortion.new(:afternoon))
    handler.match(tokens, definitions).should_not be_truthy
  end
  it("handler class 4") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["repeater_month_name", "scalar_day", "time?"], "handler")
    tokens = [Cronic::Token.new("may")]
    tokens[0].tag(Cronic::RepeaterMonthName.new(:may))
    handler.match(tokens, definitions).should_not be_truthy
    (tokens << Cronic::Token.new("27"))
    tokens[1].tag(Cronic::ScalarDay.new(27))
    handler.match(tokens, definitions).should be_truthy
  end
  it("handler class 5") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["repeater", "time?"], "handler")
    tokens = [Cronic::Token.new("friday")]
    tokens[0].tag(Cronic::RepeaterDayName.new(:friday))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("5:00"))
    tokens[1].tag(Cronic::RepeaterTime.new("5:00"))
    handler.match(tokens, definitions).should be_truthy
    (tokens << Cronic::Token.new("pm"))
    tokens[2].tag(Cronic::RepeaterDayPortion.new(:pm))
    handler.match(tokens, definitions).should be_truthy
  end
  it("handler class 6") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new(["scalar", "repeater", "pointer"], "handler")
    tokens = [Cronic::Token.new("3"), Cronic::Token.new("years"), Cronic::Token.new("past")]
    tokens[0].tag(Cronic::Scalar.new(3))
    tokens[1].tag(Cronic::RepeaterYear.new(:year))
    tokens[2].tag(Cronic::Pointer.new(:past))
    handler.match(tokens, definitions).should be_truthy
  end
  it("handler class 7") do
    definitions = Cronic::SpanDictionary.new.definitions
    handler = Cronic::Handler.new([["separator_on", "separator_at"], "scalar"], "handler")
    tokens = [Cronic::Token.new("at"), Cronic::Token.new("14")]
    tokens[0].tag(Cronic::SeparatorAt.new("at"))
    tokens[1].tag(Cronic::Scalar.new(14))
    handler.match(tokens, definitions).should be_truthy
    tokens = [Cronic::Token.new("on"), Cronic::Token.new("15")]
    tokens[0].tag(Cronic::SeparatorOn.new("on"))
    tokens[1].tag(Cronic::Scalar.new(15))
    handler.match(tokens, definitions).should be_truthy
  end
end
