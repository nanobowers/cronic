require "./spec_helper"

include Cronic

def test_tokenize(str)
  par = Cronic::Parser.new
  toks =  par.tokenize(str)
  puts toks.map(&.to_s)
  toks
end

describe "tokenizing" do
  it "tokenizes something with a time in it" do
    toks = test_tokenize("15th of january at 8am")
    toks[0].has_tag(Ordinal).should be_true
    toks[1].has_tag(RepeaterMonthName).should be_true
    toks[2].has_tag(SeparatorAt).should be_true
    toks[3].has_tag(Cronic::Scalar).should be_true
    toks[4].has_tag(RepeaterDayPortion).should be_true
  end
end

describe "lots of tokenizing" do
  it "toks" do

    test_tokenize("Ham Sandwich").should be_empty

    test_tokenize("q4 2005")
    test_tokenize("Q1 next year")
    test_tokenize("1st quarter this year")
    test_tokenize("01:00:00 PM")
    test_tokenize("03/18/2012 09:26 pm")
    test_tokenize("05/06 6:05:57 PM")
    test_tokenize("05/06")
    test_tokenize("05:00 pm may 27th")
    test_tokenize("09.08.2013")
    test_tokenize("0:10")
    test_tokenize("1 day hence")
    test_tokenize("1 fortnight ago")
    test_tokenize("1 hour from now")
    test_tokenize("1 month ago")
    test_tokenize("1 quarter ago")
    test_tokenize("1 quarter from now")
    test_tokenize("1 week from now")
    test_tokenize("1 weekend from now")
    test_tokenize("1/1")
    test_tokenize("1/13")
    test_tokenize("10 after 2")
    test_tokenize("10 before 2")
    test_tokenize("10 past 2")
    test_tokenize("10 prior to 2")
    test_tokenize("10 till 2")
    test_tokenize("10 till")
    test_tokenize("10 to 2")
    test_tokenize("10 to")
    test_tokenize("10th wednesday in november")
    test_tokenize("11 december 8am")
    test_tokenize("11th december 79")
    test_tokenize("11th december 8am")
    test_tokenize("12 am")
    test_tokenize("12 pm")
    test_tokenize("12:01 am")
    test_tokenize("12:01 pm")
    test_tokenize("1:00:00 PM")

    test_tokenize("12/1")
    test_tokenize("13/09")
    test_tokenize("13:00")
    test_tokenize("13:45")
    test_tokenize("1902-08-20")
    test_tokenize("1:01pm")
    test_tokenize("2 days from this second")
    test_tokenize("2 fortnights ago")
    test_tokenize("2 quarters ago")
    test_tokenize("2 weekends ago")
    test_tokenize("2 weekends from now")
    test_tokenize("20 minutes hence")
    test_tokenize("20 seconds before now")
    test_tokenize("20 seconds from now")
    test_tokenize("2000-1-1")
    test_tokenize("2006-08-20 03:00")
    test_tokenize("2006-08-20 03:30:30")
    test_tokenize("2006-08-20 15:30.30")
    test_tokenize("2006-08-20 15:30:30")
    test_tokenize("2006-08-20 15:30:30:000536")
    test_tokenize("2006-08-20 7pm")
    test_tokenize("2006-08-20")
    test_tokenize("2009 May 22nd")
    test_tokenize("2011-07-03 16:11:35 -05:00")
    test_tokenize("2011-07-03 21:11:35 UTC")
    test_tokenize("2011-07-03 21:11:35.362 UTC")
    test_tokenize("2011-07-03 22:11:35 +0100")
    test_tokenize("2011-07-03 22:11:35 +01:00")
    test_tokenize("2012-06")
    test_tokenize("2012:05:25 22:06:50")
    test_tokenize("2013-03-12 17:00")
    test_tokenize("2013.07.30 11:45:23")
    test_tokenize("2013.08.09")
    test_tokenize("2013/12")
    test_tokenize("22 February")
    test_tokenize("22 feb")
    test_tokenize("22-feb")
    test_tokenize("22nd February 2012")
    test_tokenize("22nd February")
    test_tokenize("24 hours 20 minutes from now")
    test_tokenize("24 hours and 20 minutes from now")
    test_tokenize("25 minutes and 20 seconds from now")
    test_tokenize("27 Oct 2006 7:30pm")
    test_tokenize("27/5/1979 @ 0700")
    test_tokenize("27/5/1979")
    test_tokenize("2867532 seconds from now")
    test_tokenize("2:01pm")
    test_tokenize("3 days ago")
    test_tokenize("3 fortnights hence")
    test_tokenize("3 jan 10")
    test_tokenize("3 jan 2010 4pm")
    test_tokenize("3 jan 2010")
    test_tokenize("3 minutes ago")
    test_tokenize("3 months ago saturday at 5:00 pm")
    test_tokenize("3 weeks ago")
    test_tokenize("3 years ago this friday")
    test_tokenize("3 years ago tomorrow")
    test_tokenize("3 years ago")
    test_tokenize("3 years from now")
    test_tokenize("3/13")
    test_tokenize("30-07-2013 21:53:49")
    test_tokenize("30-Mar-11")
    test_tokenize("30.07.2013 16:34:22")
    test_tokenize("30/2/2000")
    test_tokenize("31 of may at 6:30pm")
    test_tokenize("31-Aug-12")
    test_tokenize("31st of may at 6:30pm")
    test_tokenize("33 days from now")
    test_tokenize("3rd month next year")
    test_tokenize("3rd thursday this september")
    test_tokenize("3rd wednesday in november")
    test_tokenize("4 am")
    test_tokenize("4 pm")

    test_tokenize("4th day last week")
    test_tokenize("5 mornings ago")
    test_tokenize("5 mornings hence")
    test_tokenize("5 on may 27th")
    test_tokenize("5 on may 28")
    test_tokenize("5")
    test_tokenize("5/27/1979 4am")
    test_tokenize("5/27/1979")
    test_tokenize("5:00 pm may 27th")
    test_tokenize("5pm may 28")
    test_tokenize("5pm on may 27th")
    test_tokenize("5pm on may 28")
    test_tokenize("5th tuesday in february")
    test_tokenize("5th tuesday in january")
    test_tokenize("6 months hence")
    test_tokenize("7 hours ago")
    test_tokenize("7 hours before tomorrow at midnight")
    test_tokenize("7 tonight")
    test_tokenize("7/12/11")
    test_tokenize("8/1")
    test_tokenize("8/16/2006 at 12:15a")
    test_tokenize("8/16/2006 at 12am")
    test_tokenize("8/16/2006 at 12pm")
    test_tokenize("8/16/2006 at 6:30p")
    test_tokenize("9.8.2013")
    test_tokenize("9/19/2011 6:05:57 PM")
    test_tokenize("9am on Saturday")
    test_tokenize("A day ago")
    test_tokenize("AN hour ago")
    test_tokenize("February 14, 2004")
    test_tokenize("Fri December 30th 2005")
    test_tokenize("Jan 1,2010")
    test_tokenize("March 30th 79 4:30")
    test_tokenize("March 30th 79 at 4:30")
    test_tokenize("March 30th 79")
    test_tokenize("March 30th, 1979")
    test_tokenize("Mon Apr 02 17:00:00 PDT 2007")
    test_tokenize("November 18, 2010")
    test_tokenize("November 18th 2010 at 4")
    test_tokenize("November 18th 2010 at midnight")
    test_tokenize("November 18th 2010 midnight")
    test_tokenize("November 18th 2010")
    test_tokenize("November 18th, 2010")
    test_tokenize("Sat December 31st 2005")
    test_tokenize("Sun July 31st 2005")
    test_tokenize("Thu 16th at 4pm")
    test_tokenize("Thu 17th at 4pm")
    test_tokenize("Thu 17th")
    test_tokenize("Thu 1st at 4pm")
    test_tokenize("Thu Aug 10 2006")
    test_tokenize("Thu Aug 10 4pm")
    test_tokenize("Thu Aug 10 at 4pm")
    test_tokenize("Thu Aug 10")
    test_tokenize("Thu Aug 10th at 4pm")
    test_tokenize("Thu Aug 10th")
    test_tokenize("Thursday December 30 2006")
    test_tokenize("Thursday December 31 2006")
    test_tokenize("Thursday December 31")
    test_tokenize("Thursday December 31st")
    test_tokenize("Thursday July 31 2006")
    test_tokenize("Thursday July 31")
    test_tokenize("Thursday July 31st")
    test_tokenize("Wed Aug 10th 2005")
    test_tokenize("a month ago")
    test_tokenize("a year ago")
    test_tokenize("afternoon yesterday")
    test_tokenize("aug 20")
    test_tokenize("aug 24")
    test_tokenize("aug 3")
    test_tokenize("aug-20")
    test_tokenize("aug. 3")
    test_tokenize("eat pasty buns today at 2pm")
    test_tokenize("fifteenth of this month")
    test_tokenize("friday 1 pm")

    test_tokenize("friday 11 at night")
    test_tokenize("4:00 in the morning")
    test_tokenize("friday 11 in the evening")
    test_tokenize("friday evening at 7")
    
    test_tokenize("friday 13:00")

    test_tokenize("futuristically speaking today at 2pm")
    test_tokenize("half past 2")
    test_tokenize("in 3 hours")
    test_tokenize("jan 3 2010 at 4")
    test_tokenize("jan 3 2010 at midnight")
    test_tokenize("jan 3 2010 midnight")
    test_tokenize("jan 3 2010")


    test_tokenize("may '01")
    test_tokenize("may 10th")
    test_tokenize("may 1st 01")
    test_tokenize("may 27 32")
    test_tokenize("may 27 79 4:30")
    test_tokenize("may 27 79 at 4:30")
    test_tokenize("may 27 79")
    test_tokenize("may 27")
    test_tokenize("may 27, 1979")
    test_tokenize("may 27th 5:00 pm")
    test_tokenize("may 27th at 5")
    test_tokenize("may 27th at 5pm")
    test_tokenize("may 27th")
    test_tokenize("may 28 5pm")
    test_tokenize("may 28 at 5:32.19pm")
    test_tokenize("may 28 at 5:32:19.764")
    test_tokenize("may 28 at 5pm")
    test_tokenize("may 28")
    test_tokenize("may 32")
    test_tokenize("may 33")
    test_tokenize("may 97")
    test_tokenize("meeting today at 2pm")
    test_tokenize("monday 4:00")

    test_tokenize("november 4")
    test_tokenize("november")
    test_tokenize("oct 5 2012 1045pm")
    test_tokenize("on Tuesday")
    test_tokenize("quarter to 4")
    test_tokenize("sat 4:00")
    test_tokenize("second monday in january")
    test_tokenize("september 3 years ago")
    test_tokenize("some stupid nonsense")
    test_tokenize("sunday 4:20")
    test_tokenize("sunday 6am")
    test_tokenize("sunday at 8:15pm")
    test_tokenize("t")

    test_tokenize("today at 02:00:00 AM")
    test_tokenize("today at 02:00:00")
    test_tokenize("today at 03:00:00")
    test_tokenize("today at 2100")
    test_tokenize("today at 3:00:00")
    test_tokenize("today at 6:00am")
    test_tokenize("today at 6:00pm")
    test_tokenize("today at 9:00")
    test_tokenize("today")
    
    test_tokenize("tomorrow at 0900")
    test_tokenize("tomorrow at 4a.m.")
    test_tokenize("tomorrow evening at 7")
    test_tokenize("tomorrow morning at 5:30")
    test_tokenize("tomorrow")
    test_tokenize("tonight 7")
    test_tokenize("tonight at 7")
    test_tokenize("tonight")
    test_tokenize("tuesday last week")
    test_tokenize("two days ago 00:00:00am")
    test_tokenize("two days ago 0:0:0am")

    toks = test_tokenize("yesterday afternoon")
    toks[0].has_tag(Grabber).should be_true
    toks[1].has_tag(RepeaterDay).should be_true
    toks[2].has_tag(RepeaterDayPortion).should be_true
    
    test_tokenize("yesterday at 4:00")
    test_tokenize("yesterday at 4:00pm")
    toks = test_tokenize("yesterday")
    toks[0].has_tag(Grabber).should be_true
    toks[1].has_tag(RepeaterDay).should be_true
    
  end

  it "tokenizes grabber plus" do
    test_tokenize("last november")[1].has_tag(RepeaterMonthName).should be_true
    test_tokenize("last quarter")[1].has_tag(RepeaterQuarter).should be_true
    test_tokenize("last second")[1].has_tag(Repeater).should be_true
    test_tokenize("last spring")[1].has_tag(RepeaterSeason).should be_true
    test_tokenize("last weekend")[1].has_tag(Repeater).should be_true
    test_tokenize("last winter")[1].has_tag(RepeaterSeason).should be_true
    test_tokenize("next hr")[1].has_tag(Repeater).should be_true
    test_tokenize("next hrs")[1].has_tag(Repeater).should be_true
    test_tokenize("next min")[1].has_tag(Repeater).should be_true
    test_tokenize("next mins")[1].has_tag(Repeater).should be_true
    test_tokenize("next minute")[1].has_tag(Repeater).should be_true
    test_tokenize("next quarter")[1].has_tag(RepeaterQuarter).should be_true
    test_tokenize("next sec")[1].has_tag(Repeater).should be_true
    test_tokenize("next second")[1].has_tag(Repeater).should be_true
    test_tokenize("next secs")[1].has_tag(Repeater).should be_true

    test_tokenize("last tuesday")[1].has_tag(RepeaterDayName).should be_true
    test_tokenize("last wed")[1].has_tag(RepeaterDayName).should be_true
    test_tokenize("next tuesday")[1].has_tag(Repeater).should be_true
    test_tokenize("next wed")[1].has_tag(Repeater).should be_true

    test_tokenize("this day")[1].has_tag(Repeater).should be_true
    test_tokenize("this fortnight")[1].has_tag(Repeater).should be_true
    test_tokenize("this month")[1].has_tag(Repeater).should be_true
    test_tokenize("this morning")[1].has_tag(Repeater).should be_true
    test_tokenize("this quarter")[1].has_tag(Repeater).should be_true
    test_tokenize("this second")[1].has_tag(Repeater).should be_true
    test_tokenize("this tuesday")[1].has_tag(Repeater).should be_true
    test_tokenize("this week")[1].has_tag(Repeater).should be_true
    test_tokenize("this weekend")[1].has_tag(Repeater).should be_true
    test_tokenize("this winter")[1].has_tag(Repeater).should be_true
    test_tokenize("this year")[1].has_tag(Repeater).should be_true

    test_tokenize("last week tuesday")
    test_tokenize("last friday at 4:00")
    test_tokenize("next monday at 12:01 am")
    test_tokenize("next monday at 12:01 pm")
    test_tokenize("next wed 4:00")
    test_tokenize("this day 1800")
    test_tokenize("this day at 0900")

  end
  it "tokenizes DayName" do
    %w[mon mun tue tus wed wenns thu thur sat satterday sum sun fri friday fry].each do |txt|
      toks = test_tokenize(txt)
      toks.size.should eq 1
      toks[0].has_tag(RepeaterDayName).should be_true
    end
  end
    
  it "tokenizes grabbers" do
    %w[this next last].each do |txt|
      toks = test_tokenize(txt)
      toks.size.should eq 1
      toks[0].has_tag(Grabber).should be_true
    end
  end

  it "tokenizes pointers" do
    %w[future past].each do |txt|
      toks = test_tokenize(txt)
      toks.size.should eq 1
      toks[0].has_tag(Cronic::Pointer).should be_true, txt
    end
  end

end
