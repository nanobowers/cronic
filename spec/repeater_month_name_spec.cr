require "./spec_helper"

describe Cronic::RepeaterMonthName do


  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("next") do
    mays = Cronic::RepeaterMonthName.new(:may)
    mays.start = @now
    next_may = mays.next(:future)
    next_may.begin.should eq Time.local(2007, 5)
    next_may.end.should eq Time.local(2007, 6)
    next_next_may = mays.next(:future)
    next_next_may.begin.should eq Time.local(2008, 5)
    next_next_may.end.should eq Time.local(2008, 6)
    decembers = Cronic::RepeaterMonthName.new(:december)
    decembers.start = @now
    next_december = decembers.next(:future)
    next_december.begin.should eq Time.local(2006, 12)
    next_december.end.should eq Time.local(2007, 1)
    mays = Cronic::RepeaterMonthName.new(:may)
    mays.start = @now
    mays.next(:past).begin.should eq Time.local(2006, 5)
    mays.next(:past).begin.should eq Time.local(2005, 5)
  end
  it("this") do
    octobers = Cronic::RepeaterMonthName.new(:october)
    octobers.start = @now
    this_october = octobers.this(:future)
    this_october.begin.should eq Time.local(2006, 10, 1)
    this_october.end.should eq Time.local(2006, 11, 1)
    aprils = Cronic::RepeaterMonthName.new(:april)
    aprils.start = @now
    this_april = aprils.this(:past)
    this_april.begin.should eq Time.local(2006, 4, 1)
    this_april.end.should eq Time.local(2006, 5, 1)
  end
end
