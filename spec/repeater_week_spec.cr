require "./spec_helper"

describe Cronic::RepeaterWeek do
  it("next future") do
    weeks = Cronic::RepeaterWeek.new(:week)
    weeks.start = now_time
    next_week = weeks.next(Cronic::PointerDir::Future)
    next_week.begin.should eq Time.local(2006, 8, 20)
    next_week.end.should eq Time.local(2006, 8, 27)
    next_next_week = weeks.next(Cronic::PointerDir::Future)
    next_next_week.begin.should eq Time.local(2006, 8, 27)
    next_next_week.end.should eq Time.local(2006, 9, 3)
  end
  it("next past") do
    weeks = Cronic::RepeaterWeek.new(:week)
    weeks.start = now_time
    last_week = weeks.next(Cronic::PointerDir::Past)
    last_week.begin.should eq Time.local(2006, 8, 6)
    last_week.end.should eq Time.local(2006, 8, 13)
    last_last_week = weeks.next(Cronic::PointerDir::Past)
    last_last_week.begin.should eq Time.local(2006, 7, 30)
    last_last_week.end.should eq Time.local(2006, 8, 6)
  end
  it("this future") do
    weeks = Cronic::RepeaterWeek.new(:week)
    weeks.start = now_time
    this_week = weeks.this(Cronic::PointerDir::Future)
    this_week.begin.should eq Time.local(2006, 8, 16, 15)
    this_week.end.should eq Time.local(2006, 8, 20)
  end
  it("this past") do
    weeks = Cronic::RepeaterWeek.new(:week)
    weeks.start = now_time
    this_week = weeks.this(Cronic::PointerDir::Past)
    this_week.begin.should eq Time.local(2006, 8, 13, 0)
    this_week.end.should eq Time.local(2006, 8, 16, 14)
  end
  it("offset") do
    span = Cronic::SecSpan.new(now_time, (now_time + Time::Span.new(seconds: 1)))
    offset_span = Cronic::RepeaterWeek.new(:week).offset(span, 3, Cronic::PointerDir::Future)
    offset_span.begin.should eq Time.local(2006, 9, 6, 14)
    offset_span.end.should eq Time.local(2006, 9, 6, 14, 0, 1)
  end
  it("next future starting on monday") do
    weeks = Cronic::RepeaterWeek.new(:week, nil, week_start: :monday)
    weeks.start = now_time
    next_week = weeks.next(Cronic::PointerDir::Future)
    next_week.begin.should eq Time.local(2006, 8, 21)
    next_week.end.should eq Time.local(2006, 8, 28)
    next_next_week = weeks.next(Cronic::PointerDir::Future)
    next_next_week.begin.should eq Time.local(2006, 8, 28)
    next_next_week.end.should eq Time.local(2006, 9, 4)
  end
  it("next past starting on monday") do
    weeks = Cronic::RepeaterWeek.new(:week, nil, week_start: :monday)
    weeks.start = now_time
    last_week = weeks.next(Cronic::PointerDir::Past)
    last_week.begin.should eq Time.local(2006, 8, 7)
    last_week.end.should eq Time.local(2006, 8, 14)
    last_last_week = weeks.next(Cronic::PointerDir::Past)
    last_last_week.begin.should eq Time.local(2006, 7, 31)
    last_last_week.end.should eq Time.local(2006, 8, 7)
  end
  it("this future starting on monday") do
    weeks = Cronic::RepeaterWeek.new(:week, nil, week_start: :monday)
    weeks.start = now_time
    this_week = weeks.this(Cronic::PointerDir::Future)
    this_week.begin.should eq Time.local(2006, 8, 16, 15)
    this_week.end.should eq Time.local(2006, 8, 21)
  end
  it("this past starting on monday") do
    weeks = Cronic::RepeaterWeek.new(:week, nil, week_start: :monday)
    weeks.start = now_time
    this_week = weeks.this(Cronic::PointerDir::Past)
    this_week.begin.should eq Time.local(2006, 8, 14, 0)
    this_week.end.should eq Time.local(2006, 8, 16, 14)
  end
  it("offset starting on monday") do
    weeks = Cronic::RepeaterWeek.new(:week, nil, week_start: :monday)
    span = Cronic::SecSpan.new(now_time, (now_time + Time::Span.new(seconds: 1)))
    offset_span = weeks.offset(span, 3, Cronic::PointerDir::Future)
    offset_span.begin.should eq Time.local(2006, 9, 6, 14)
    offset_span.end.should eq Time.local(2006, 9, 6, 14, 0, 1)
  end
end
