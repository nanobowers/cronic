require "./spec_helper"

describe Cronic::RepeaterFortnight do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }
  
  it("next future") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = @now
    next_fortnight = fortnights.next(:future)
    next_fortnight.begin.should eq Time.local(2006, 8, 20)
    next_fortnight.end.should eq Time.local(2006, 9, 3)
    next_next_fortnight = fortnights.next(:future)
    next_next_fortnight.begin.should eq Time.local(2006, 9, 3)
    next_next_fortnight.end.should eq Time.local(2006, 9, 17)
  end
  it("next past") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = @now
    last_fortnight = fortnights.next(:past)
    last_fortnight.begin.should eq Time.local(2006, 7, 30)
    last_fortnight.end.should eq Time.local(2006, 8, 13)
    last_last_fortnight = fortnights.next(:past)
    last_last_fortnight.begin.should eq Time.local(2006, 7, 16)
    last_last_fortnight.end.should eq Time.local(2006, 7, 30)
  end
  it("this future") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = @now
    this_fortnight = fortnights.this(:future)
    this_fortnight.begin.should eq Time.local(2006, 8, 16, 15)
    this_fortnight.end.should eq Time.local(2006, 8, 27)
  end
  it("this past") do
    fortnights = Cronic::RepeaterFortnight.new(:fortnight)
    fortnights.start = @now
    this_fortnight = fortnights.this(:past)
    this_fortnight.begin.should eq Time.local(2006, 8, 13, 0)
    this_fortnight.end.should eq Time.local(2006, 8, 16, 14)
  end
  it("offset") do
    span = Cronic::Span.new(@now, (@now + 1))
    offset_span = Cronic::RepeaterWeek.new(:week).offset(span, 3, :future)
    offset_span.begin.should eq Time.local(2006, 9, 6, 14)
    offset_span.end.should eq Time.local(2006, 9, 6, 14, 0, 1)
  end
end
