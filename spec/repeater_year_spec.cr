require "./spec_helper"

describe Cronic::RepeaterYear do
  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }
  it("next future") do
    years = Cronic::RepeaterYear.new(:year)
    years.start = @now
    next_year = years.next(:future)
    next_year.begin.should eq Time.local(2007, 1, 1)
    next_year.end.should eq Time.local(2008, 1, 1)
    next_next_year = years.next(:future)
    next_next_year.begin.should eq Time.local(2008, 1, 1)
    next_next_year.end.should eq Time.local(2009, 1, 1)
  end
  it("next past") do
    years = Cronic::RepeaterYear.new(:year)
    years.start = @now
    last_year = years.next(:past)
    last_year.begin.should eq Time.local(2005, 1, 1)
    last_year.end.should eq Time.local(2006, 1, 1)
    last_last_year = years.next(:past)
    last_last_year.begin.should eq Time.local(2004, 1, 1)
    last_last_year.end.should eq Time.local(2005, 1, 1)
  end
  it("this") do
    years = Cronic::RepeaterYear.new(:year)
    years.start = @now
    this_year = years.this(:future)
    this_year.begin.should eq Time.local(2006, 8, 17)
    this_year.end.should eq Time.local(2007, 1, 1)
    this_year = years.this(:past)
    this_year.begin.should eq Time.local(2006, 1, 1)
    this_year.end.should eq Time.local(2006, 8, 16)
  end
  it("offset") do
    span = Cronic::Span.new(@now, (@now + 1))
    offset_span = Cronic::RepeaterYear.new(:year).offset(span, 3, :future)
    offset_span.begin.should eq Time.local(2009, 8, 16, 14)
    offset_span.end.should eq Time.local(2009, 8, 16, 14, 0, 1)
    offset_span = Cronic::RepeaterYear.new(:year).offset(span, 10, :past)
    offset_span.begin.should eq Time.local(1996, 8, 16, 14)
    offset_span.end.should eq Time.local(1996, 8, 16, 14, 0, 1)
    now = Time.local(2008, 2, 29)
    span = Cronic::Span.new(now, (now + 1))
    offset_span = Cronic::RepeaterYear.new(:year).offset(span, 1, :past)
    offset_span.begin.should eq Time.local(2007, 2, 28)
    offset_span.end.should eq Time.local(2007, 2, 28, 0, 0, 1)
  end
end
