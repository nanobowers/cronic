require "./spec_helper"

def ref_time_min
  Time.local(2008, 6, 25, 7, 15, 30)
end

describe Cronic::RepeaterMinute do
  it("next future") do
    minutes = Cronic::RepeaterMinute.new(:minute)
    minutes.start = ref_time_min
    next_minute = minutes.next(Cronic::PointerDir::Future)
    next_minute.begin.should eq Time.local(2008, 6, 25, 7, 16)
    next_minute.end.should eq Time.local(2008, 6, 25, 7, 17)
    next_next_minute = minutes.next(Cronic::PointerDir::Future)
    next_next_minute.begin.should eq Time.local(2008, 6, 25, 7, 17)
    next_next_minute.end.should eq Time.local(2008, 6, 25, 7, 18)
  end
  it("next past") do
    minutes = Cronic::RepeaterMinute.new(:minute)
    minutes.start = ref_time_min
    prev_minute = minutes.next(Cronic::PointerDir::Past)
    prev_minute.begin.should eq Time.local(2008, 6, 25, 7, 14)
    prev_minute.end.should eq Time.local(2008, 6, 25, 7, 15)
    prev_prev_minute = minutes.next(Cronic::PointerDir::Past)
    prev_prev_minute.begin.should eq Time.local(2008, 6, 25, 7, 13)
    prev_prev_minute.end.should eq Time.local(2008, 6, 25, 7, 14)
  end
end
