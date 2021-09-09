require "./spec_helper"

describe Cronic::RepeaterTime do

  it("generic") do
    expect_raises(ArgumentError) {
      Cronic::RepeaterTime.new("00:01:02:03:004")
    }
  end
  
  it("next future") do
    t = Cronic::RepeaterTime.new("4:00")
    t.start = now_time
    t.next(:future).begin.should eq Time.local(2006, 8, 16, 16)
    t.next(:future).begin.should eq Time.local(2006, 8, 17, 4)
    t = Cronic::RepeaterTime.new("13:00")
    t.start = now_time
    t.next(:future).begin.should eq Time.local(2006, 8, 17, 13)
    t.next(:future).begin.should eq Time.local(2006, 8, 18, 13)
    t = Cronic::RepeaterTime.new("0400")
    t.start = now_time
    t.next(:future).begin.should eq Time.local(2006, 8, 17, 4)
    t.next(:future).begin.should eq Time.local(2006, 8, 18, 4)
    t = Cronic::RepeaterTime.new("0000")
    t.start = now_time
    t.next(:future).begin.should eq Time.local(2006, 8, 17, 0)
    t.next(:future).begin.should eq Time.local(2006, 8, 18, 0)
  end
  it("next past") do
    t = Cronic::RepeaterTime.new("4:00")
    t.start = now_time
    t.next(:past).begin.should eq Time.local(2006, 8, 16, 4)
    t.next(:past).begin.should eq Time.local(2006, 8, 15, 16)
    t = Cronic::RepeaterTime.new("13:00")
    t.start = now_time
    t.next(:past).begin.should eq Time.local(2006, 8, 16, 13)
    t.next(:past).begin.should eq Time.local(2006, 8, 15, 13)
    t = Cronic::RepeaterTime.new("0:00.000")
    t.start = now_time
    t.next(:past).begin.should eq Time.local(2006, 8, 16, 0)
    t.next(:past).begin.should eq Time.local(2006, 8, 15, 0)
  end
  it("type") do
    t1 = Cronic::RepeaterTime.new("4")
    t1.type.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("14")
    t1.type.time.should eq 50400
    t1 = Cronic::RepeaterTime.new("4:00")
    t1.type.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("4:30")
    t1.type.time.should eq 16200
    t1 = Cronic::RepeaterTime.new("1400")
    t1.type.time.should eq 50400
    t1 = Cronic::RepeaterTime.new("0400")
    t1.type.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("04")
    t1.type.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("400")
    t1.type.time.should eq 14400
  end
end
