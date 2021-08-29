require "./spec_helper"

describe Cronic::RepeaterSeason do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("next future") do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = @now
    next_season = seasons.next(:future)
    next_season.begin.should eq Time.local(2006, 9, 23)
    next_season.end.should eq Time.local(2006, 12, 21)
  end
  it("next past") do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = @now
    last_season = seasons.next(:past)
    last_season.begin.should eq Time.local(2006, 3, 20)
    last_season.end.should eq Time.local(2006, 6, 20)
  end
  it("this") do
    seasons = Cronic::RepeaterSeason.new(:season)
    seasons.start = @now
    this_season = seasons.this(:future)
    this_season.begin.should eq Time.local(2006, 8, 17)
    this_season.end.should eq Time.local(2006, 9, 22)
    this_season = seasons.this(:past)
    this_season.begin.should eq Time.local(2006, 6, 21)
    this_season.end.should eq Time.local(2006, 8, 16)
  end
end
