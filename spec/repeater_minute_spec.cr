require "./spec_helper"

describe Cronic::RepeaterMinute do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("next future") do
    minutes = Cronic::RepeaterMinute.new(:minute)
    minutes.start = @now
    next_minute = minutes.next(:future)
    next_minute.begin.should eq Time.local(2008, 6, 25, 7, 16)
    next_minute.end.should eq Time.local(2008, 6, 25, 7, 17)
    next_next_minute = minutes.next(:future)
    next_next_minute.begin.should eq Time.local(2008, 6, 25, 7, 17)
    next_next_minute.end.should eq Time.local(2008, 6, 25, 7, 18)
  end
  it("next past") do
    minutes = Cronic::RepeaterMinute.new(:minute)
    minutes.start = @now
    prev_minute = minutes.next(:past)
    prev_minute.begin.should eq Time.local(2008, 6, 25, 7, 14)
    prev_minute.end.should eq Time.local(2008, 6, 25, 7, 15)
    prev_prev_minute = minutes.next(:past)
    prev_prev_minute.begin.should eq Time.local(2008, 6, 25, 7, 13)
    prev_prev_minute.end.should eq Time.local(2008, 6, 25, 7, 14)
  end
end
