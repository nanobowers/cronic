require "./spec_helper"
describe Cronic::RepeaterWeekday do
  now : Time
  Spec.before_each { now = Time.local(2007, 6, 11, 14, 0, 0, 0) }
  it("next future") do
    weekdays = Cronic::RepeaterWeekday.new(:weekday)
    weekdays.start = @now
    next1_weekday = weekdays.next(:future)
    next1_weekday.begin.should eq Time.local(2007, 6, 12)
    next1_weekday.end.should eq Time.local(2007, 6, 13)
    next2_weekday = weekdays.next(:future)
    next2_weekday.begin.should eq Time.local(2007, 6, 13)
    next2_weekday.end.should eq Time.local(2007, 6, 14)
    next3_weekday = weekdays.next(:future)
    next3_weekday.begin.should eq Time.local(2007, 6, 14)
    next3_weekday.end.should eq Time.local(2007, 6, 15)
    next4_weekday = weekdays.next(:future)
    next4_weekday.begin.should eq Time.local(2007, 6, 15)
    next4_weekday.end.should eq Time.local(2007, 6, 16)
    next5_weekday = weekdays.next(:future)
    next5_weekday.begin.should eq Time.local(2007, 6, 18)
    next5_weekday.end.should eq Time.local(2007, 6, 19)
  end
  it("next past") do
    weekdays = Cronic::RepeaterWeekday.new(:weekday)
    weekdays.start = @now
    last1_weekday = weekdays.next(:past)
    last1_weekday.begin.should eq Time.local(2007, 6, 8)
    last1_weekday.end.should eq Time.local(2007, 6, 9)
    last2_weekday = weekdays.next(:past)
    last2_weekday.begin.should eq Time.local(2007, 6, 7)
    last2_weekday.end.should eq Time.local(2007, 6, 8)
  end
  it("offset") do
    span = Cronic::Span.new(@now, (@now + 1))
    offset_span = Cronic::RepeaterWeekday.new(:weekday).offset(span, 5, :future)
    offset_span.begin.should eq Time.local(2007, 6, 18, 14)
    offset_span.end.should eq Time.local(2007, 6, 18, 14, 0, 1)
  end
end
