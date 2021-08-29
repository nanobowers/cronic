require "./spec_helper"

describe Cronic::RepeaterDayName do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("match") do
    token = Cronic::Token.new("saturday")
    repeater = Cronic::Repeater.scan_for_day_names(token)
    repeater.class.should eq Cronic::RepeaterDayName
    repeater.type.should eq :saturday
    token = Cronic::Token.new("sunday")
    repeater = Cronic::Repeater.scan_for_day_names(token)
    repeater.class.should eq Cronic::RepeaterDayName
    repeater.type.should eq :sunday
  end
  it("next future") do
    mondays = Cronic::RepeaterDayName.new(:monday)
    mondays.start = @now
    span = mondays.next(:future)
    span.begin.should eq Time.local(2006, 8, 21)
    span.end.should eq Time.local(2006, 8, 22)
    span = mondays.next(:future)
    span.begin.should eq Time.local(2006, 8, 28)
    span.end.should eq Time.local(2006, 8, 29)
  end
  it("next past") do
    mondays = Cronic::RepeaterDayName.new(:monday)
    mondays.start = @now
    span = mondays.next(:past)
    span.begin.should eq Time.local(2006, 8, 14)
    span.end.should eq Time.local(2006, 8, 15)
    span = mondays.next(:past)
    span.begin.should eq Time.local(2006, 8, 7)
    span.end.should eq Time.local(2006, 8, 8)
  end
end
