require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterQuarterName do
  it "matches quarter names" do
    %w[q1 q2 q3 q4].each do |qtr|
      token = Cronic::Token.new(qtr)
      repeater = Cronic::Repeater.scan_for_quarter_names(token)
      repeater.class.should eq Cronic::RepeaterQuarterName
      repeater.try(&.type).should eq qtr.upcase
    end
  end

  it "gets this quarter" do
    quarter = Cronic::RepeaterQuarterName.new(Cronic::QuarterNames::Q1)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::None)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(Cronic::QuarterNames::Q2)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::None)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(Cronic::QuarterNames::Q3)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::None)
    time.try(&.begin).should eq Time.local(2006, 7, 1)
    time.try(&.end).should eq Time.local(2006, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(Cronic::QuarterNames::Q4)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::None)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
  end

  it "gets this past quarter" do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 7, 1)
    time.try(&.end).should eq Time.local(2005, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 10, 1)
    time.try(&.end).should eq Time.local(2006, 1, 1)
  end

  it "gets this future quarter" do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 1, 1)
    time.try(&.end).should eq Time.local(2007, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 4, 1)
    time.try(&.end).should eq Time.local(2007, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 7, 1)
    time.try(&.end).should eq Time.local(2007, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.this(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
  end
  it("next future") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 1, 1)
    time.try(&.end).should eq Time.local(2007, 4, 1)
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2008, 1, 1)
    time.try(&.end).should eq Time.local(2008, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 4, 1)
    time.try(&.end).should eq Time.local(2007, 7, 1)
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2008, 4, 1)
    time.try(&.end).should eq Time.local(2008, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 7, 1)
    time.try(&.end).should eq Time.local(2007, 10, 1)
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2008, 7, 1)
    time.try(&.end).should eq Time.local(2008, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
    time = quarter.next(Cronic::PointerDir::Future)
    time.try(&.begin).should eq Time.local(2007, 10, 1)
    time.try(&.end).should eq Time.local(2008, 1, 1)
  end
  it("next past") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 1, 1)
    time.try(&.end).should eq Time.local(2005, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 4, 1)
    time.try(&.end).should eq Time.local(2005, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 7, 1)
    time.try(&.end).should eq Time.local(2005, 10, 1)
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2004, 7, 1)
    time.try(&.end).should eq Time.local(2004, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2005, 10, 1)
    time.try(&.end).should eq Time.local(2006, 1, 1)
    time = quarter.next(Cronic::PointerDir::Past)
    time.try(&.begin).should eq Time.local(2004, 10, 1)
    time.try(&.end).should eq Time.local(2005, 1, 1)
  end
end
