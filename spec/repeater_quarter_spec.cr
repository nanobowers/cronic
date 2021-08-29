require "./spec_helper"

describe Cronic::RepeaterQuarter do
  
  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  
  it("match") do
    token = Cronic::Token.new("q")
    repeater = Cronic::Repeater.scan_for_units(token)
    repeater.class.should eq Cronic::RepeaterQuarter
    repeater.type.should eq :quarter
  end
  it("this") do
    quarter = Cronic::RepeaterQuarter.new(:quarter)
    quarter.start = @now
    time = quarter.this
    time.begin.should eq Time.local(2006, 7, 1)
    time.end.should eq Time.local(2006, 10, 1)
  end
  it("next future") do
    quarter = Cronic::RepeaterQuarter.new(:quarter)
    quarter.start = @now
    time = quarter.next(:future)
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 1, 1)
    time.end.should eq Time.local(2007, 4, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 4, 1)
    time.end.should eq Time.local(2007, 7, 1)
  end
  it("next past") do
    quarter = Cronic::RepeaterQuarter.new(:quarter)
    quarter.start = @now
    time = quarter.next(:past)
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2006, 1, 1)
    time.end.should eq Time.local(2006, 4, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2005, 10, 1)
    time.end.should eq Time.local(2006, 1, 1)
  end
  it("offset") do
    quarter = Cronic::RepeaterQuarter.new(:quarter)
    span = Cronic::Span.new(@now, (@now + 1))
    time = quarter.offset(span, 1, :future)
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
    time = quarter.offset(span, 1, :past)
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
  end
end
