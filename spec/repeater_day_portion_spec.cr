require "../src/cronic"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterDayPortion do
  it("am future") do
    day_portion = Cronic::RepeaterDayPortion.new(:am)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 17, 0)
    next_time.end.should eq Time.local(2006, 8, 17, 11, 59, 59)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 18, 0)
    next_next_time.end.should eq Time.local(2006, 8, 18, 11, 59, 59)
  end
  it("am past") do
    day_portion = Cronic::RepeaterDayPortion.new(:am)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 16, 0)
    next_time.end.should eq Time.local(2006, 8, 16, 11, 59, 59)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 15, 0)
    next_next_time.end.should eq Time.local(2006, 8, 15, 11, 59, 59)
  end
  it("am future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:am)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 4, 0)
    next_time.end.should eq Time.local(2012, 11, 4, 11, 59, 59)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 5, 0)
    next_next_time.end.should eq Time.local(2012, 11, 5, 11, 59, 59)
  end
  it("pm future") do
    day_portion = Cronic::RepeaterDayPortion.new(:pm)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 17, 12)
    next_time.end.should eq Time.local(2006, 8, 17, 23, 59, 59)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 18, 12)
    next_next_time.end.should eq Time.local(2006, 8, 18, 23, 59, 59)
  end
  it("pm past") do
    day_portion = Cronic::RepeaterDayPortion.new(:pm)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 15, 12)
    next_time.end.should eq Time.local(2006, 8, 15, 23, 59, 59)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 14, 12)
    next_next_time.end.should eq Time.local(2006, 8, 14, 23, 59, 59)
  end
  it("pm future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:pm)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 3, 12)
    next_time.end.should eq Time.local(2012, 11, 3, 23, 59, 59)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 4, 12)
    next_next_time.end.should eq Time.local(2012, 11, 4, 23, 59, 59)
  end
  it("morning future") do
    day_portion = Cronic::RepeaterDayPortion.new(:morning)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 17, 6)
    next_time.end.should eq Time.local(2006, 8, 17, 12)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 18, 6)
    next_next_time.end.should eq Time.local(2006, 8, 18, 12)
  end
  it("morning past") do
    day_portion = Cronic::RepeaterDayPortion.new(:morning)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 16, 6)
    next_time.end.should eq Time.local(2006, 8, 16, 12)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 15, 6)
    next_next_time.end.should eq Time.local(2006, 8, 15, 12)
  end
  it("morning future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:morning)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 3, 6)
    next_time.end.should eq Time.local(2012, 11, 3, 12)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 4, 6)
    next_next_time.end.should eq Time.local(2012, 11, 4, 12)
  end
  it("afternoon future") do
    day_portion = Cronic::RepeaterDayPortion.new(:afternoon)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 17, 13)
    next_time.end.should eq Time.local(2006, 8, 17, 17)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 18, 13)
    next_next_time.end.should eq Time.local(2006, 8, 18, 17)
  end
  it("afternoon past") do
    day_portion = Cronic::RepeaterDayPortion.new(:afternoon)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 15, 13)
    next_time.end.should eq Time.local(2006, 8, 15, 17)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 14, 13)
    next_next_time.end.should eq Time.local(2006, 8, 14, 17)
  end
  it("afternoon future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:afternoon)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 3, 13)
    next_time.end.should eq Time.local(2012, 11, 3, 17)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 4, 13)
    next_next_time.end.should eq Time.local(2012, 11, 4, 17)
  end
  it("evening future") do
    day_portion = Cronic::RepeaterDayPortion.new(:evening)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 16, 17)
    next_time.end.should eq Time.local(2006, 8, 16, 20)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 17, 17)
    next_next_time.end.should eq Time.local(2006, 8, 17, 20)
  end
  it("evening past") do
    day_portion = Cronic::RepeaterDayPortion.new(:evening)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 15, 17)
    next_time.end.should eq Time.local(2006, 8, 15, 20)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 14, 17)
    next_next_time.end.should eq Time.local(2006, 8, 14, 20)
  end
  it("evening future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:evening)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 3, 17)
    next_time.end.should eq Time.local(2012, 11, 3, 20)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 4, 17)
    next_next_time.end.should eq Time.local(2012, 11, 4, 20)
  end
  it("night future") do
    day_portion = Cronic::RepeaterDayPortion.new(:night)
    day_portion.start = now_time
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2006, 8, 16, 20)
    next_time.end.should eq Time.local(2006, 8, 17, 0)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2006, 8, 17, 20)
    next_next_time.end.should eq Time.local(2006, 8, 18, 0)
  end
  it("night past") do
    day_portion = Cronic::RepeaterDayPortion.new(:night)
    day_portion.start = now_time
    next_time = day_portion.next(:past)
    next_time.begin.should eq Time.local(2006, 8, 15, 20)
    next_time.end.should eq Time.local(2006, 8, 16, 0)
    next_next_time = day_portion.next(:past)
    next_next_time.begin.should eq Time.local(2006, 8, 14, 20)
    next_next_time.end.should eq Time.local(2006, 8, 15, 0)
  end
  it("night future with daylight savings time boundary") do
    now = Time.local(2012, 11, 3, 0, 0, 0)
    day_portion = Cronic::RepeaterDayPortion.new(:night)
    day_portion.start = now
    next_time = day_portion.next(:future)
    next_time.begin.should eq Time.local(2012, 11, 3, 20)
    next_time.end.should eq Time.local(2012, 11, 4, 0)
    next_next_time = day_portion.next(:future)
    next_next_time.begin.should eq Time.local(2012, 11, 4, 20)
    next_next_time.end.should eq Time.local(2012, 11, 5, 0)
  end
end
