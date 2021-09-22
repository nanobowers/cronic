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
    t1 = Cronic::RepeaterTime.new("4") # 4 hours
    t1.tagtype.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("14") # 14 hours
    t1.tagtype.time.should eq 50400
    t1 = Cronic::RepeaterTime.new("4:00") # 4 hours
    t1.tagtype.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("4:30") # 4 hours, 30 min
    t1.tagtype.time.should eq 16200
    t1 = Cronic::RepeaterTime.new("1400") # 14 hours
    t1.tagtype.time.should eq 50400
    t1 = Cronic::RepeaterTime.new("0400") # 4 hours
    t1.tagtype.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("04") # 4 hours
    t1.tagtype.time.should eq 14400
    t1 = Cronic::RepeaterTime.new("400") # 4 hours
    t1.tagtype.time.should eq 14400

    t1 = Cronic::RepeaterTime.new("4:19:37") # 4h, 19m, 37s
    t1.tagtype.time.should eq 15577

    t1 = Cronic::RepeaterTime.new("4:19:37:029") # 4h, 19m, 37s, 29msec
    t1.tagtype.time.should eq 15577.029

    t1 = Cronic::RepeaterTime.new("12:19") # Interpret as 12-hr clk 12:19am, i.e. 0h,19m
    t1.tagtype.time.should eq (19*60)

    t1 = Cronic::RepeaterTime.new("12:19", hours24: true) # 12h, 19m
    t1.tagtype.time.should eq (12*3600 + 19*60)
  end
end
