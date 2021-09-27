require "./spec_helper"

def now_time
  Time.local(2006, 8, 16, 14, 0, 0)
end

describe Cronic::RepeaterSeason do
  it "next future" do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = now_time
    next_season = seasons.next(Cronic::PointerDir::Future)
    next_season.begin.should eq Time.local(2006, 9, 23)
    next_season.end.should eq Time.local(2006, 12, 21)
  end
  it "next past" do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = now_time
    last_season = seasons.next(Cronic::PointerDir::Past)
    last_season.begin.should eq Time.local(2006, 3, 20)
    last_season.end.should eq Time.local(2006, 6, 20)
  end
  it "this" do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = now_time
    this_season = seasons.this(Cronic::PointerDir::Future)
    this_season.begin.should eq Time.local(2006, 8, 17)
    this_season.end.should eq Time.local(2006, 9, 22)
    this_season = seasons.this(Cronic::PointerDir::Past)
    this_season.begin.should eq Time.local(2006, 6, 21)
    this_season.end.should eq Time.local(2006, 8, 16)
  end
end
