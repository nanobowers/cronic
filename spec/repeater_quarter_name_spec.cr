require "./spec_helper"

describe Cronic::RepeaterQuarterName do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("match") do
    ["q1", "q2", "q3", "q4"].each do |string|
      token = Cronic::Token.new(string)
      repeater = Cronic::Repeater.scan_for_quarter_names(token)
      repeater.class.should eq Cronic::RepeaterQuarterName
      repeater.type.should eq string.to_sym
    end
  end
  it("this none") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = @now
    time = quarter.this(:none)
    time.begin.should eq Time.local(2006, 1, 1)
    time.end.should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = @now
    time = quarter.this(:none)
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = @now
    time = quarter.this(:none)
    time.begin.should eq Time.local(2006, 7, 1)
    time.end.should eq Time.local(2006, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = @now
    time = quarter.this(:none)
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
  end
  it("this past") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = @now
    time = quarter.this(:past)
    time.begin.should eq Time.local(2006, 1, 1)
    time.end.should eq Time.local(2006, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = @now
    time = quarter.this(:past)
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = @now
    time = quarter.this(:past)
    time.begin.should eq Time.local(2005, 7, 1)
    time.end.should eq Time.local(2005, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = @now
    time = quarter.this(:past)
    time.begin.should eq Time.local(2005, 10, 1)
    time.end.should eq Time.local(2006, 1, 1)
  end
  it("this future") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = @now
    time = quarter.this(:future)
    time.begin.should eq Time.local(2007, 1, 1)
    time.end.should eq Time.local(2007, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = @now
    time = quarter.this(:future)
    time.begin.should eq Time.local(2007, 4, 1)
    time.end.should eq Time.local(2007, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = @now
    time = quarter.this(:future)
    time.begin.should eq Time.local(2007, 7, 1)
    time.end.should eq Time.local(2007, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = @now
    time = quarter.this(:future)
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
  end
  it("next future") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = @now
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 1, 1)
    time.end.should eq Time.local(2007, 4, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2008, 1, 1)
    time.end.should eq Time.local(2008, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = @now
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 4, 1)
    time.end.should eq Time.local(2007, 7, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2008, 4, 1)
    time.end.should eq Time.local(2008, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = @now
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 7, 1)
    time.end.should eq Time.local(2007, 10, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2008, 7, 1)
    time.end.should eq Time.local(2008, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = @now
    time = quarter.next(:future)
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
    time = quarter.next(:future)
    time.begin.should eq Time.local(2007, 10, 1)
    time.end.should eq Time.local(2008, 1, 1)
  end
  it("next past") do
    quarter = Cronic::RepeaterQuarterName.new(:q1)
    quarter.start = @now
    time = quarter.next(:past)
    time.begin.should eq Time.local(2006, 1, 1)
    time.end.should eq Time.local(2006, 4, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2005, 1, 1)
    time.end.should eq Time.local(2005, 4, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q2)
    quarter.start = @now
    time = quarter.next(:past)
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2005, 4, 1)
    time.end.should eq Time.local(2005, 7, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q3)
    quarter.start = @now
    time = quarter.next(:past)
    time.begin.should eq Time.local(2005, 7, 1)
    time.end.should eq Time.local(2005, 10, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2004, 7, 1)
    time.end.should eq Time.local(2004, 10, 1)
    quarter = Cronic::RepeaterQuarterName.new(:q4)
    quarter.start = @now
    time = quarter.next(:past)
    time.begin.should eq Time.local(2005, 10, 1)
    time.end.should eq Time.local(2006, 1, 1)
    time = quarter.next(:past)
    time.begin.should eq Time.local(2004, 10, 1)
    time.end.should eq Time.local(2005, 1, 1)
  end
end
