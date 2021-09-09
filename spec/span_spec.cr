require "./spec_helper"

describe "TestSpan" do

  it("span width") do
    span = Cronic::SecSpan.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    span.width.should eq ((60 * 60) * 24)
  end
  it("span math") do
    s = Cronic::SecSpan.new(1, 2)
    (s + 1).begin.should eq 2
    (s + 1).end.should eq 3
    (s - 1).begin.should eq 0
    (s - 1).end.should eq 1
  end
end
