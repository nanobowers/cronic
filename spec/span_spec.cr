require "./spec_helper"

describe "TestSpan" do
  it "span width" do
    span = Cronic::SecSpan.new(Time.local(2006, 8, 16, 0), Time.local(2006, 8, 17, 0))
    span.width.should eq ((60 * 60) * 24)
  end
  it "span math" do
    t1 = Time.local(2001, 1, 1, 0, 0, 1)
    t2 = Time.local(2001, 1, 1, 0, 0, 2)
    s = Cronic::SecSpan.new(t1, t2)

    (s + 1.second).begin.second.should eq 2
    (s + 1.second).end.second.should eq 3

    (s - 1.second).begin.second.should eq 0
    (s - 1.second).end.second.should eq 1
  end
end
