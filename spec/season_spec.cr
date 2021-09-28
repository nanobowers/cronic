require "./spec_helper"

def ref_spring_day
  Time.local(2008, 4, 8, 0, 0, 0)
end

def ref_summer_day
  Time.local(2008, 7, 4, 0, 0, 0)
end

def ref_autumn_day
  Time.local(2008, 10, 10, 0, 0, 0)
end

def ref_winter_day
  Time.local(2008, 12, 31, 0, 0, 0)
end

include Cronic

describe Season do
  it "finds the next winter from spring" do
    span = Season.span_for_next_season(ref_spring_day, Season::Winter, PointerDir::Future)
    span.begin.year.should eq 2008
    span.begin.month.should eq 12
    span.end.year.should eq 2009
    span.end.month.should eq 3
  end

  it "finds the next autumn from spring" do
    span = Season.span_for_next_season(ref_spring_day, Season::Autumn, PointerDir::Future)
    span.begin.year.should eq 2008
    span.begin.month.should eq 9
    span.end.year.should eq 2008
    span.end.month.should eq 12
  end

  it "finds next year's spring from summer" do
    span = Season.span_for_next_season(ref_summer_day, Season::Spring, PointerDir::Future)
    span.begin.year.should eq 2009
    span.begin.month.should eq 3
    span.end.year.should eq 2009
    span.end.month.should eq 6
  end

  it "finds last year's winter from spring" do
    span = Season.span_for_next_season(ref_spring_day, Season::Winter, PointerDir::Past)
    span.begin.year.should eq 2007
    span.begin.month.should eq 12
    span.end.year.should eq 2008
    span.end.month.should eq 3
  end

  it "finds last year's autumn from spring" do
    span = Season.span_for_next_season(ref_spring_day, Season::Autumn, PointerDir::Past)
    span.begin.year.should eq 2007
    span.begin.month.should eq 9
    span.end.year.should eq 2007
    span.end.month.should eq 12
  end

  it "finds the current season if time is in it" do
    span = Season.span_for_next_season(ref_spring_day, Season::Spring, PointerDir::Past)
    span.begin.year.should eq 2008
    span.begin.month.should eq 3
    span.end.year.should eq 2008
    span.end.month.should eq 6
    span = Season.span_for_next_season(ref_spring_day, Season::Spring, PointerDir::None)
    span.begin.year.should eq 2008
    span.begin.month.should eq 3
    span.end.year.should eq 2008
    span.end.month.should eq 6
    span = Season.span_for_next_season(ref_spring_day, Season::Spring, PointerDir::Future)
    span.begin.year.should eq 2008
    span.begin.month.should eq 3
    span.end.year.should eq 2008
    span.end.month.should eq 6
  end
end
