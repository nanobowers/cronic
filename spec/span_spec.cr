require "./spec_helper"

describe "TestSpan" do

  it("span width") do
    span = Cronic::SecSpan.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    span.width.should eq ((60 * 60) * 24)
  end
  it("span math") do
    s = Cronic::SecSpan.new(Time.local(2001,1,1,1), Time.local(2001,1,1,2))
    (s + 1.minute).begin.should eq 2.minutes
    (s + 1.minute).end.should eq 3.minutes
    (s - 1.minute).begin.should eq 0.minutes
    (s - 1.minute).end.should eq 1.minute
  end
end
