require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterHour do

  it("next future") do
    hours = Cronic::RepeaterHour.new(:hour)
    hours.start = now_time
    next_hour = hours.next(:future)
    next_hour.begin.should eq Time.local(2006, 8, 16, 15)
    next_hour.end.should eq Time.local(2006, 8, 16, 16)
    next_next_hour = hours.next(:future)
    next_next_hour.begin.should eq Time.local(2006, 8, 16, 16)
    next_next_hour.end.should eq Time.local(2006, 8, 16, 17)
  end
  it("next past") do
    hours = Cronic::RepeaterHour.new(:hour)
    hours.start = now_time
    past_hour = hours.next(:past)
    past_hour.begin.should eq Time.local(2006, 8, 16, 13)
    past_hour.end.should eq Time.local(2006, 8, 16, 14)
    past_past_hour = hours.next(:past)
    past_past_hour.begin.should eq Time.local(2006, 8, 16, 12)
    past_past_hour.end.should eq Time.local(2006, 8, 16, 13)
  end
  it("this") do
    now = Time.local(2006, 8, 16, 14, 30)
    hours = Cronic::RepeaterHour.new(:hour)
    hours.start = now
    this_hour = hours.this(:future)
    this_hour.begin.should eq Time.local(2006, 8, 16, 14, 31)
    this_hour.end.should eq Time.local(2006, 8, 16, 15)
    this_hour = hours.this(:past)
    this_hour.begin.should eq Time.local(2006, 8, 16, 14)
    this_hour.end.should eq Time.local(2006, 8, 16, 14, 30)
    this_hour = hours.this(:none)
    this_hour.begin.should eq Time.local(2006, 8, 16, 14)
    this_hour.end.should eq Time.local(2006, 8, 16, 15)
  end
  it("offset") do
    span = Cronic::SecSpan.new(now_time, (now_time + Time::Span.new(seconds: 1)))
    offset_span = Cronic::RepeaterHour.new(:hour).offset(span, 3, :future)
    offset_span.begin.should eq Time.local(2006, 8, 16, 17)
    offset_span.end.should eq Time.local(2006, 8, 16, 17, 0, 1)
    offset_span = Cronic::RepeaterHour.new(:hour).offset(span, 24, :past)
    offset_span.begin.should eq Time.local(2006, 8, 15, 14)
    offset_span.end.should eq Time.local(2006, 8, 15, 14, 0, 1)
  end
end
