require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterQuarterName do
  it "matches quarter names" do
    [:q1, :q2, :q3, :q4].each do |sym|
      token = Cronic::Token.new(sym.to_s)
      repeater = Cronic::Repeater.scan_for_quarter_names(token)
      repeater.class.should eq Cronic::RepeaterQuarterName
      repeater.try(&.type).should eq sym
    end
  end

  it "gets this quarter" do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.this(:none)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.this(:none)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.this(:none)
    time.try(&.begin).should eq Time.local(2006, 7, 1)
    time.try(&.end).should eq Time.local(2006, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.this(:none)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
  end

  it "gets this past quarter" do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.this(:past)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.this(:past)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.this(:past)
    time.try(&.begin).should eq Time.local(2005, 7, 1)
    time.try(&.end).should eq Time.local(2005, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.this(:past)
    time.try(&.begin).should eq Time.local(2005, 10, 1)
    time.try(&.end).should eq Time.local(2006, 1, 1)
  end

  it "gets this future quarter" do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.this(:future)
    time.try(&.begin).should eq Time.local(2007, 1, 1)
    time.try(&.end).should eq Time.local(2007, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.this(:future)
    time.try(&.begin).should eq Time.local(2007, 4, 1)
    time.try(&.end).should eq Time.local(2007, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.this(:future)
    time.try(&.begin).should eq Time.local(2007, 7, 1)
    time.try(&.end).should eq Time.local(2007, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.this(:future)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
  end
  it("next future") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2007, 1, 1)
    time.try(&.end).should eq Time.local(2007, 4, 1)
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2008, 1, 1)
    time.try(&.end).should eq Time.local(2008, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2007, 4, 1)
    time.try(&.end).should eq Time.local(2007, 7, 1)
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2008, 4, 1)
    time.try(&.end).should eq Time.local(2008, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2007, 7, 1)
    time.try(&.end).should eq Time.local(2007, 10, 1)
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2008, 7, 1)
    time.try(&.end).should eq Time.local(2008, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2006, 10, 1)
    time.try(&.end).should eq Time.local(2007, 1, 1)
    time = quarter.next(:future)
    time.try(&.begin).should eq Time.local(2007, 10, 1)
    time.try(&.end).should eq Time.local(2008, 1, 1)
  end
  it("next past") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = now_time
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2006, 1, 1)
    time.try(&.end).should eq Time.local(2006, 4, 1)
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2005, 1, 1)
    time.try(&.end).should eq Time.local(2005, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = now_time
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2006, 4, 1)
    time.try(&.end).should eq Time.local(2006, 7, 1)
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2005, 4, 1)
    time.try(&.end).should eq Time.local(2005, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = now_time
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2005, 7, 1)
    time.try(&.end).should eq Time.local(2005, 10, 1)
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2004, 7, 1)
    time.try(&.end).should eq Time.local(2004, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = now_time
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2005, 10, 1)
    time.try(&.end).should eq Time.local(2006, 1, 1)
    time = quarter.next(:past)
    time.try(&.begin).should eq Time.local(2004, 10, 1)
    time.try(&.end).should eq Time.local(2005, 1, 1)
  end
end
