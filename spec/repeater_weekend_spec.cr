require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterWeekend do
  it "next future" do
    weekend = Cronic::RepeaterWeekend.new(:weekend)
    weekend.start = now_time
    next_weekend = weekend.next(Cronic::PointerDir::Future).as(Cronic::SecSpan)
    next_weekend.begin.should eq Time.local(2006, 8, 19)
    next_weekend.end.should eq Time.local(2006, 8, 21)
  end
  it "next past" do
    weekend = Cronic::RepeaterWeekend.new(:weekend)
    weekend.start = now_time
    next_weekend = weekend.next(Cronic::PointerDir::Past).as(Cronic::SecSpan)
    next_weekend.begin.should eq Time.local(2006, 8, 12)
    next_weekend.end.should eq Time.local(2006, 8, 14)
  end
  it "this future" do
    weekend = Cronic::RepeaterWeekend.new(:weekend)
    weekend.start = now_time
    next_weekend = weekend.this(Cronic::PointerDir::Future).as(Cronic::SecSpan)
    next_weekend.begin.should eq Time.local(2006, 8, 19)
    next_weekend.end.should eq Time.local(2006, 8, 21)
  end
  it "this past" do
    weekend = Cronic::RepeaterWeekend.new(:weekend)
    weekend.start = now_time
    next_weekend = weekend.this(Cronic::PointerDir::Past).as(Cronic::SecSpan)
    next_weekend.begin.should eq Time.local(2006, 8, 12)
    next_weekend.end.should eq Time.local(2006, 8, 14)
  end
  it "this none" do
    weekend = Cronic::RepeaterWeekend.new(:weekend)
    weekend.start = now_time
    next_weekend = weekend.this(Cronic::PointerDir::Future).as(Cronic::SecSpan)
    next_weekend.begin.should eq Time.local(2006, 8, 19)
    next_weekend.end.should eq Time.local(2006, 8, 21)
  end
  it "offset" do
    span = Cronic::SecSpan.new(now_time, (now_time + ::Time::Span.new(seconds: 1)))
    offset_span = Cronic::RepeaterWeekend.new(:weekend).offset(span, 3, Cronic::PointerDir::Future)
    offset_span.begin.should eq Time.local(2006, 9, 2)
    offset_span.end.should eq Time.local(2006, 9, 2, 0, 0, 1)
    offset_span = Cronic::RepeaterWeekend.new(:weekend).offset(span, 1, Cronic::PointerDir::Past)
    offset_span.begin.should eq Time.local(2006, 8, 12)
    offset_span.end.should eq Time.local(2006, 8, 12, 0, 0, 1)
    offset_span = Cronic::RepeaterWeekend.new(:weekend).offset(span, 0, Cronic::PointerDir::Future)
    offset_span.begin.should eq Time.local(2006, 8, 12)
    offset_span.end.should eq Time.local(2006, 8, 12, 0, 0, 1)
  end
end
