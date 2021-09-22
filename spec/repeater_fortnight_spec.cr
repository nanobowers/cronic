require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterFortnight do
  it("next future") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = now_time
    next_fortnight = fortnights.next(:future).as(Cronic::SecSpan)
    next_fortnight.begin.should eq Time.local(2006, 8, 20)
    next_fortnight.end.should eq Time.local(2006, 9, 3)
    next_next_fortnight = fortnights.next(:future)
    next_next_fortnight.begin.should eq Time.local(2006, 9, 3)
    next_next_fortnight.end.should eq Time.local(2006, 9, 17)
  end
  it("next past") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = now_time
    last_fortnight = fortnights.next(:past).as(Cronic::SecSpan)
    last_fortnight.begin.should eq Time.local(2006, 7, 30)
    last_fortnight.end.should eq Time.local(2006, 8, 13)
    last_last_fortnight = fortnights.next(:past)
    last_last_fortnight.begin.should eq Time.local(2006, 7, 16)
    last_last_fortnight.end.should eq Time.local(2006, 7, 30)
  end
  it("this future") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = now_time
    this_fortnight = fortnights.this(:future).as(Cronic::SecSpan)
    this_fortnight.begin.should eq Time.local(2006, 8, 16, 15)
    this_fortnight.end.should eq Time.local(2006, 8, 27)
  end
  it("this past") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = now_time
    this_fortnight = fortnights.this(:past).as(Cronic::SecSpan)
    this_fortnight.begin.should eq Time.local(2006, 8, 13, 0)
    this_fortnight.end.should eq Time.local(2006, 8, 16, 14)
  end
  it("offset") do
    span = Cronic::SecSpan.new(now_time, (now_time + Time::Span.new(seconds: 1)))
    offset_span = Cronic::RepeaterWeek.new(:week).offset(span, 3, :future)
    offset_span.begin.should eq Time.local(2006, 9, 6, 14)
    offset_span.end.should eq Time.local(2006, 9, 6, 14, 0, 1)
  end
end
