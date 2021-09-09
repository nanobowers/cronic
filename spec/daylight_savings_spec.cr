require "./spec_helper"

def begin_daylight_savings
  Time.local(2008, 3, 9, 5, 0, 0)
end
def end_daylight_savings
  Time.local(2008, 11, 2, 5, 0, 0)
end
describe "daylight-savings" do

  it("begin past") do
    t = Cronic::RepeaterTime.new("900")
    t.start = begin_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 3, 8, 21)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 3, 9, 22, 0, 0)
    t.next(:past).begin.should eq Time.local(2008, 3, 9, 21)
    t = Cronic::RepeaterTime.new("400")
    t.start = begin_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 3, 9, 4)
    t = Cronic::RepeaterTime.new("0400")
    t.start = begin_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 3, 9, 4)
    t = Cronic::RepeaterTime.new("1300")
    t.start = begin_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 3, 8, 13)
  end
  it("begin future") do
    t = Cronic::RepeaterTime.new("900")
    t.start = begin_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 3, 9, 9)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 3, 9, 13, 0, 0)
    t.next(:future).begin.should eq Time.local(2008, 3, 9, 21)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 3, 9, 22, 0, 0)
    t.next(:future).begin.should eq Time.local(2008, 3, 10, 9)
    t = Cronic::RepeaterTime.new("0900")
    t.start = begin_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 3, 9, 9)
    t = Cronic::RepeaterTime.new("0400")
    t.start = begin_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 3, 10, 4)
  end
  it("end past") do
    t = Cronic::RepeaterTime.new("900")
    t.start = end_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 11, 1, 21)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 11, 2, 22, 0, 0)
    t.next(:past).begin.should eq Time.local(2008, 11, 2, 21)
    t = Cronic::RepeaterTime.new("400")
    t.start = end_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 11, 2, 4)
    t = Cronic::RepeaterTime.new("0400")
    t.start = end_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 11, 2, 4)
    t = Cronic::RepeaterTime.new("1300")
    t.start = end_daylight_savings
    t.next(:past).begin.should eq Time.local(2008, 11, 1, 13)
  end
  it("end future") do
    t = Cronic::RepeaterTime.new("900")
    t.start = end_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 11, 2, 9)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 11, 2, 13, 0, 0)
    t.next(:future).begin.should eq Time.local(2008, 11, 2, 21)
    t = Cronic::RepeaterTime.new("900")
    t.start = Time.local(2008, 11, 2, 22, 0, 0)
    t.next(:future).begin.should eq Time.local(2008, 11, 3, 9)
    t = Cronic::RepeaterTime.new("0900")
    t.start = end_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 11, 2, 9)
    t = Cronic::RepeaterTime.new("0400")
    t.start = end_daylight_savings
    t.next(:future).begin.should eq Time.local(2008, 11, 3, 4)
  end
end
