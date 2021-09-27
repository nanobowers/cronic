require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterDayName do
  it "match" do
    token = Cronic::Token.new("saturday")
    repeater = Cronic::Repeater.scan_for_day_names(token)
    repeater.class.should eq Cronic::RepeaterDayName
    repeater.try(&.day).should eq Time::DayOfWeek::Saturday
    token = Cronic::Token.new("sunday")
    repeater = Cronic::Repeater.scan_for_day_names(token)
    repeater.class.should eq Cronic::RepeaterDayName
    repeater.try(&.day).should eq Time::DayOfWeek::Sunday
  end
  it "next future" do
    mondays = Cronic::RepeaterDayName.new(:monday)
    mondays.start = now_time
    span = mondays.next(Cronic::PointerDir::Future)
    span.begin.should eq Time.local(2006, 8, 21)
    span.end.should eq Time.local(2006, 8, 22)
    span = mondays.next(Cronic::PointerDir::Future)
    span.begin.should eq Time.local(2006, 8, 28)
    span.end.should eq Time.local(2006, 8, 29)
  end
  it "next past" do
    mondays = Cronic::RepeaterDayName.new(:monday)
    mondays.start = now_time
    span = mondays.next(Cronic::PointerDir::Past)
    span.begin.should eq Time.local(2006, 8, 14)
    span.end.should eq Time.local(2006, 8, 15)
    span = mondays.next(Cronic::PointerDir::Past)
    span.begin.should eq Time.local(2006, 8, 7)
    span.end.should eq Time.local(2006, 8, 8)
  end
end
