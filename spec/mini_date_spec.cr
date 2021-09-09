require "./spec_helper"

describe Cronic::MiniDate do
  it "fails when given an invalid month" do
    expect_raises(ArgumentError) { Cronic::MiniDate.new(0, 12) }
    expect_raises(ArgumentError) { Cronic::MiniDate.new(13, 1) }
  end
  it("is between") do
    m = Cronic::MiniDate.new(3, 2)
    m.is_between?(Cronic::MiniDate.new(2, 4), Cronic::MiniDate.new(4, 7)).should eq true
    m.is_between?(Cronic::MiniDate.new(1, 5), Cronic::MiniDate.new(2, 7)).should eq false
    m = Cronic::MiniDate.new(12, 24)
    m.is_between?(Cronic::MiniDate.new(10, 1), Cronic::MiniDate.new(12, 21)).should eq false
  end
  it("is between short range") do
    m = Cronic::MiniDate.new(5, 10)
    m.is_between?(Cronic::MiniDate.new(5, 3), Cronic::MiniDate.new(5, 12)).should eq true
    m.is_between?(Cronic::MiniDate.new(5, 11), Cronic::MiniDate.new(5, 15)).should eq false
  end
  it("is between wrapping range") do
    m = Cronic::MiniDate.new(1, 1)
    m.is_between?(Cronic::MiniDate.new(11, 11), Cronic::MiniDate.new(2, 2)).should eq true
    m = Cronic::MiniDate.new(12, 12)
    m.is_between?(Cronic::MiniDate.new(11, 11), Cronic::MiniDate.new(1, 5)).should eq true
  end
end
