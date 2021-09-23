require "spec"
require "../src/cronic"

TIME_2006_08_16_14_00_00 = Time.local(2006, 8, 16, 14, 0, 0)

def parse_now(str, **kwargs)
  Cronic.parse(str, **kwargs, now: TIME_2006_08_16_14_00_00)
end

def parse_now_span(str, **kwargs)
  Cronic.parse_span(str, **kwargs, now: TIME_2006_08_16_14_00_00)
end

def pre_normalize(str)
  Cronic::Parser.new.pre_normalize(str)
end

include Cronic

describe Cronic::Parser do
  it("parses generics") do
    time = Cronic.parse("2012-08-02T13:00:00")
    time.should eq Time.local(2012, 8, 2, 13)
    time = Cronic.parse("2012-08-02T13:00:00+01:00")
    time.should eq Time.utc(2012, 8, 2, 12)
    time = Cronic.parse("2012-08-02T08:00:00-04:00")
    time.should eq Time.utc(2012, 8, 2, 12)
  end

  it "parses rfc3339" do
    time = Cronic.parse("2013-08-01T19:30:00.345-07:00")
    time2 = Time.parse_rfc3339("2013-08-01T19:30:00.345-07:00")
    (time - time2).abs.to_f.should be_close(0, 0.001)

    time = Cronic.parse("2013-08-01T19:30:00.34-07:00")
    time2 = Time.parse_rfc3339("2013-08-01T19:30:00.34-07:00")
    (time - time2).abs.to_f.should be_close(0, 0.001)

    time = Cronic.parse("2013-08-01T19:30:00.3456789-07:00")
    time2 = Time.parse_rfc3339("2013-08-01T19:30:00.3456789-07:00")
    (time - time2).abs.to_f.should be_close(0, 0.001)
  end

  it "parses generics (2)" do
    time = Cronic.parse("2012-08-02T12:00:00Z")
    time.should eq Time.utc(2012, 8, 2, 12)

    time = Cronic.parse("2012-01-03 01:00:00.100")
    time2 = Time.parse("2012-01-03T01:00:00.100", "%Y-%m-%dT%H:%M:%S.%3N", Time::Location.local)
    (time - time2).abs.to_f.should be_close(0, 0.001)

    time = Cronic.parse("2012-01-03 01:00:00.234567")
    time2 = Time.parse("2012-01-03T01:00:00.234567", "%Y-%m-%dT%H:%M:%S.%6N", Time::Location.local)
    (time - time2).abs.to_f.should be_close(0, 1.0e-06)

    expect_raises(Cronic::UnknownParseError) {
      Cronic.parse("1/1/32.1") # .should be_nil
    }
  end

  it "parses raw ordinals as days of the week" do
    time = Cronic.parse("28th", guess: Cronic::Guess::Begin)
    time.should eq Time.local(Time.local.year, Time.local.month, 28)
    time = Cronic.parse("2nd", guess: Cronic::Guess::Begin)
    time.should eq Time.local(Time.local.year, Time.local.month, 2)
  end

  describe "RepeaterMonthName ScalarDay" do
    it("handles basic cases") do
      time = parse_now("aug 3")
      time.should eq Time.local(2007, 8, 3, 12)
      time = parse_now("aug. 3")
      time.should eq Time.local(2007, 8, 3, 12)
      time = parse_now("aug 20")
      time.should eq Time.local(2006, 8, 20, 12)
      time = parse_now("aug-20")
      time.should eq Time.local(2006, 8, 20, 12)
      time = parse_now("may 27")
      time.should eq Time.local(2007, 5, 27, 12)
    end
    it "handles past context" do
      time = parse_now("aug 3", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 3, 12)
      time = parse_now("may 28", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 28, 12)
    end
    it "handles future context" do
      time = parse_now("aug 20", context: Cronic::PointerDir::Future)
      time.should eq Time.local(2006, 8, 20, 12)
    end
    it "also accepts a time" do
      time = parse_now("may 28 5pm", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 28, 17)
      time = parse_now("may 28 at 5pm", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 28, 17)
      time = parse_now("may 28 at 5:32.19pm", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 28, 17, 32, 19)
    end
    it "handles nanoseconds" do
      time = parse_now("may 28 at 5:32:19.764")
      reftime = Time.local(2007, 5, 28, 17, 32, 19, nanosecond: 764000000)
      (time - reftime).abs.to_f.should be_close(0, 0.001)
    end
  end

  it("handle rmn sd on") do
    time = parse_now("5pm on may 28")
    time.should eq Time.local(2007, 5, 28, 17)
    time = parse_now("5pm may 28")
    time.should eq Time.local(2007, 5, 28, 17)
    time = parse_now("5 on may 28", ambiguous_time_range: nil)
    time.should eq Time.local(2007, 5, 28, 5)
  end

  describe "RepeaterMonthName OrdinalDay" do
    it "parses a date" do
      time = parse_now("may 27th")
      time.should eq Time.local(2007, 5, 27, 12)
    end
    it "parses a date in the past" do
      time = parse_now("may 27th", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 12)
    end
    it "parses a date in the past with a time" do
      time = parse_now("may 27th 5:00 pm", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 17)
    end
    it "parses a date in the past with a time (2)" do
      time = parse_now("may 27th at 5pm", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 17)
    end
    it "parses a date in the past with a time (3)" do
      time = parse_now("may 27th at 5", ambiguous_time_range: nil)
      time.should eq Time.local(2007, 5, 27, 5)
    end
  end

  describe "OrdinalDay RepeaterMonthName" do
    it("handles relative to the now-month") do
      time = parse_now("fifteenth of this month")
      time.should eq Time.local(2007, 8, 15, 12)
    end
  end

  describe "ordinal day repeater month name" do
    it "handles od rmn" do
      time = parse_now("22nd February")
      time.should eq Time.local(2007, 2, 22, 12)
    end
    it "handles od rmn with time" do
      time = parse_now("31st of may at 6:30pm")
      time.should eq Time.local(2007, 5, 31, 18, 30)
    end
    it "handles od rmn with time (2)" do
      time = parse_now("11th december 8am")
      time.should eq Time.local(2006, 12, 11, 8)
    end
  end

  describe "ScalarYear-RepeaterMonthName-OrdinalDay" do
    it "parses" do
      time = parse_now("2009 May 22nd")
      time.should eq Time.local(2009, 5, 22, 12)
    end
  end
  describe "ScalarDay-RepeaterMonthName" do
    it("parses basic cases") do
      time = parse_now("22 February")
      time.should eq Time.local(2007, 2, 22, 12)
      time = parse_now("22 feb")
      time.should eq Time.local(2007, 2, 22, 12)
      time = parse_now("22-feb")
      time.should eq Time.local(2007, 2, 22, 12)
    end
    it "parses cases with times" do
      time = parse_now("31 of may at 6:30pm")
      time.should eq Time.local(2007, 5, 31, 18, 30)
      time = parse_now("11 december 8am")
      time.should eq Time.local(2006, 12, 11, 8)
    end
  end
  describe "RepeaterMonthName-ScalarDay-ON" do
    it "parses" do
      time = parse_now("5:00 pm may 27th", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 17)
      time = parse_now("05:00 pm may 27th", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 17)
      time = parse_now("5pm on may 27th", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 5, 27, 17)
      time = parse_now("5 on may 27th", ambiguous_time_range: nil)
      time.should eq Time.local(2007, 5, 27, 5)
    end
  end

  describe "RepeaterMonthName-ScalarYear" do
    it "parses 1997" do
      time = parse_now("may 97")
      time.should eq Time.local(1997, 5, 16, 12)
    end
    it "parses 2030s" do
      time = parse_now("may 33", ambiguous_year_future_bias: 10)
      time.should eq Time.local(2033, 5, 16, 12)
      time = parse_now("may 32")
      time.should eq Time.local(2032, 5, 16, 12, 0, 0)
    end
    it "parses tick-year" do
      time = parse_now("may '01")
      time.should eq Time.local(2001, 5, 16, 12, 0, 0)
    end
  end

  it("handle rdn rmn sd t tz sy") do
    time = parse_now("Mon Apr 02 17:00:00 PDT 2007")
    time.to_unix.should eq 1175558400
  end

  it("handle sy sm sd t tz") do
    time = parse_now("2011-07-03 22:11:35 +0100")
    time.to_unix.should eq 1309727495
    time = parse_now("2011-07-03 22:11:35 +01:00")
    time.to_unix.should eq 1309727495
    time = parse_now("2011-07-03 16:11:35 -05:00")
    time.to_unix.should eq 1309727495
    time = parse_now("2011-07-03 21:11:35 UTC")
    time.to_unix.should eq 1309727495
    time = parse_now("2011-07-03 21:11:35.362 UTC")
    time.to_unix_f.should be_close(1309727495.362, 0.001)
  end

  describe "RepeaterMonthName-ScalarDay-ScalarYear" do
    it("parses basic cases") do
      time = parse_now("November 18, 2010")
      time.should eq Time.local(2010, 11, 18, 12)
      time = parse_now("Jan 1,2010")
      time.should eq Time.local(2010, 1, 1, 12)
      time = parse_now("February 14, 2004")
      time.should eq Time.local(2004, 2, 14, 12)
      time = parse_now("jan 3 2010")
      time.should eq Time.local(2010, 1, 3, 12)
    end
    it "parses with times" do
      time = parse_now("jan 3 2010 midnight")
      time.should eq Time.local(2010, 1, 4, 0)
      time = parse_now("jan 3 2010 at midnight")
      time.should eq Time.local(2010, 1, 4, 0)
      time = parse_now("jan 3 2010 at 4", ambiguous_time_range: nil)
      time.should eq Time.local(2010, 1, 3, 4)
    end

    it "parses in the past" do
      time = parse_now("may 27, 1979")
      time.should eq Time.local(1979, 5, 27, 12)
    end

    it "parses in the past (shortyear)" do
      time = parse_now("may 27 79")
      time.should eq Time.local(1979, 5, 27, 12)
    end

    it "parses in the past with times" do
      time = parse_now("may 27 79 4:30")
      time.should eq Time.local(1979, 5, 27, 16, 30)
      time = parse_now("may 27 79 at 4:30", ambiguous_time_range: nil)
      time.should eq Time.local(1979, 5, 27, 4, 30)
      time = parse_now("oct 5 2012 1045pm")
      time.should eq Time.local(2012, 10, 5, 22, 45)
    end
    it "parses in the future" do
      time = parse_now("may 27 32")
      time.should eq Time.local(2032, 5, 27, 12, 0, 0)
    end
  end

  describe "RepeaterMonthName-OrdinalDay-ScalarYear" do
    it "parses short-year" do
      time = parse_now("may 1st 01")
      time.should eq Time.local(2001, 5, 1, 12)
    end
    it "parses basic cases" do
      time = parse_now("November 18th 2010")
      time.should eq Time.local(2010, 11, 18, 12)
      time = parse_now("November 18th, 2010")
      time.should eq Time.local(2010, 11, 18, 12)
    end
    it "parses cases with time" do
      time = parse_now("November 18th 2010 midnight")
      time.should eq Time.local(2010, 11, 19, 0)
      time = parse_now("November 18th 2010 at midnight")
      time.should eq Time.local(2010, 11, 19, 0)
      time = parse_now("November 18th 2010 at 4")
      time.should eq Time.local(2010, 11, 18, 16)
      time = parse_now("November 18th 2010 at 4", ambiguous_time_range: nil)
      time.should eq Time.local(2010, 11, 18, 4)
    end
    it "parses cases in the past" do
      time = parse_now("March 30th, 1979")
      time.should eq Time.local(1979, 3, 30, 12)
    end
    it "parses cases in the past with short-year" do
      time = parse_now("March 30th 79")
      time.should eq Time.local(1979, 3, 30, 12)
    end
    it "parses cases in the past with time" do
      time = parse_now("March 30th 79 4:30")
      time.should eq Time.local(1979, 3, 30, 16, 30)
      time = parse_now("March 30th 79 at 4:30", ambiguous_time_range: nil)
      time.should eq Time.local(1979, 3, 30, 4, 30)
    end
  end

  describe "OrdinalDay-RepeaterMonthName-ScalarYear" do
    it "parses with a longyear" do
      time = parse_now("22nd February 2012")
      time.should eq Time.local(2012, 2, 22, 12)
    end
    it "parses with a shortyear" do
      time = parse_now("11th december 79")
      time.should eq Time.local(1979, 12, 11, 12)
    end
  end

  it "handle sd rmn sy" do
    time = parse_now("3 jan 2010")
    time.should eq Time.local(2010, 1, 3, 12)
    time = parse_now("3 jan 2010 4pm")
    time.should eq Time.local(2010, 1, 3, 16)
    time = parse_now("27 Oct 2006 7:30pm")
    time.should eq Time.local(2006, 10, 27, 19, 30)
    time = parse_now("3 jan 10")
    time.should eq Time.local(2010, 1, 3, 12)
    time = parse_now("3 jan 10", endian_precedence: [DateEndian::DayMonth])
    time.should eq Time.local(2010, 1, 3, 12)
    time = parse_now("3 jan 10", endian_precedence: [DateEndian::MonthDay])
    time.should eq Time.local(2010, 1, 3, 12)
  end
  it "handle sm sd sy" do
    time = parse_now("5/27/1979")
    time.should eq Time.local(1979, 5, 27, 12)
    time = parse_now("5/27/1979 4am")
    time.should eq Time.local(1979, 5, 27, 4)
    time = parse_now("7/12/11")
    time.should eq Time.local(2011, 7, 12, 12)
    time = parse_now("7/12/11", endian_precedence: [DateEndian::DayMonth])
    time.should eq Time.local(2011, 12, 7, 12)
    time = parse_now("9/19/2011 6:05:57 PM")
    time.should eq Time.local(2011, 9, 19, 18, 5, 57)
    expect_raises(Cronic::UnknownParseError) {
      time = parse_now("30/2/2000")
      time.should be_nil
    }
  end
  it "handles something like rfc3339 but not really" do
    time = parse_now("2013-03-12 17:00", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2013, 3, 12, 17, 0, 0)
  end

  it "handle sd sm sy" do
    time = parse_now("27/5/1979")
    time.should eq Time.local(1979, 5, 27, 12)
    time = parse_now("27/5/1979 @ 0700")
    time.should eq Time.local(1979, 5, 27, 7)
    time = parse_now("03/18/2012 09:26 pm")
    time.should eq Time.local(2012, 3, 18, 21, 26)
    time = parse_now("30.07.2013 16:34:22")
    time.should eq Time.local(2013, 7, 30, 16, 34, 22)
    time = parse_now("09.08.2013")
    time.should eq Time.local(2013, 8, 9, 12)

    # Euro-dot-date-format From Chronic.rb#356 >>>>
    time = parse_now("9.8.2013")
    time.should eq Time.local(2013, 8, 9, 12)

    time = parse_now("09.08.13")
    time.should eq Time.local(2013, 8, 9, 12)

    time = parse_now("9.8.13")
    time.should eq Time.local(2013, 8, 9, 12)
    # <<<<<
    
    time = parse_now("30-07-2013 21:53:49")
    time.should eq Time.local(2013, 7, 30, 21, 53, 49)
  end
  it("handle sy sm sd") do
    time = parse_now("2000-1-1")
    time.should eq Time.local(2000, 1, 1, 12)
    time = parse_now("2006-08-20")
    time.should eq Time.local(2006, 8, 20, 12)
    time = parse_now("2006-08-20 7pm")
    time.should eq Time.local(2006, 8, 20, 19)
    time = parse_now("2006-08-20 03:00")
    time.should eq Time.local(2006, 8, 20, 3)
    time = parse_now("2006-08-20 03:30:30")
    time.should eq Time.local(2006, 8, 20, 3, 30, 30)
    time = parse_now("2006-08-20 15:30:30")
    time.should eq Time.local(2006, 8, 20, 15, 30, 30)
    time = parse_now("2006-08-20 15:30.30")
    time.should eq Time.local(2006, 8, 20, 15, 30, 30)
    time = parse_now("2006-08-20 15:30:30:000536")
    reftime = Time.local(2006, 8, 20, 15, 30, 30, nanosecond: 536000)
    (time - reftime).abs.to_f.should be_close(0.0, 1.0e-06)
    time = parse_now("1902-08-20")
    time.should eq Time.local(1902, 8, 20, 12, 0, 0)
    time = parse_now("2013.07.30 11:45:23")
    time.should eq Time.local(2013, 7, 30, 11, 45, 23)
    time = parse_now("2013.08.09")
    time.should eq Time.local(2013, 8, 9, 12, 0, 0)
    time = parse_now("2012:05:25 22:06:50")
    time.should eq Time.local(2012, 5, 25, 22, 6, 50)
  end
  it("handle sm sd") do
    time = parse_now("05/06")
    time.should eq Time.local(2007, 5, 6, 12)
    time = parse_now("05/06", endian_precedence: ([DateEndian::DayMonth, DateEndian::MonthDay]))
    time.should eq Time.local(2007, 6, 5, 12)
    time = parse_now("05/06 6:05:57 PM")
    time.should eq Time.local(2007, 5, 6, 18, 5, 57)
    time = parse_now("05/06 6:05:57 PM", endian_precedence: ([DateEndian::DayMonth, DateEndian::MonthDay]))
    time.should eq Time.local(2007, 6, 5, 18, 5, 57)
    time = parse_now("13/09")
    time.should eq Time.local(2006, 9, 13, 12)
    time = parse_now("05/06")
    time.should eq Time.local(2007, 5, 6, 12)
    time = parse_now("1/13", context: Cronic::PointerDir::Future)
    time.should eq Time.local(2007, 1, 13, 12)
    time = parse_now("3/13", context: Cronic::PointerDir::None)
    time.should eq Time.local(2006, 3, 13, 12)
    time = parse_now("12/1", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2005, 12, 1, 12)
    time = parse_now("12/1", context: Cronic::PointerDir::Future)
    time.should eq Time.local(2006, 12, 1, 12)
    time = parse_now("12/1", context: Cronic::PointerDir::None)
    time.should eq Time.local(2006, 12, 1, 12)
    time = parse_now("8/1", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2006, 8, 1, 12)
    time = parse_now("8/1", context: Cronic::PointerDir::Future)
    time.should eq Time.local(2007, 8, 1, 12)
    time = parse_now("8/1", context: Cronic::PointerDir::None)
    time.should eq Time.local(2006, 8, 1, 12)
    time = parse_now("1/1", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2006, 1, 1, 12)
    time = parse_now("1/1", context: Cronic::PointerDir::Future)
    time.should eq Time.local(2007, 1, 1, 12)
    time = parse_now("1/1", context: Cronic::PointerDir::None)
    time.should eq Time.local(2006, 1, 1, 12)
  end

  it("handle sy sm") do
    time = parse_now("2012-06")
    time.should eq Time.local(2012, 6, 16)
    time = parse_now("2013/12")
    time.should eq Time.local(2013, 12, 16, 12, 0)
  end

  it("handle r") do
    time = parse_now("9am on Saturday")
    time.should eq Time.local(2006, 8, 19, 9)
    time = parse_now("on Tuesday")
    time.should eq Time.local(2006, 8, 22, 12)
    time = parse_now("1:00:00 PM")
    time.should eq Time.local(2006, 8, 16, 13)
    time = parse_now("01:00:00 PM")
    time.should eq Time.local(2006, 8, 16, 13)
    time = parse_now("today at 02:00:00", hours24: false)
    time.should eq Time.local(2006, 8, 16, 14)
    time = parse_now("today at 02:00:00 AM", hours24: false)
    time.should eq Time.local(2006, 8, 16, 2)
    time = parse_now("today at 3:00:00", hours24: true)
    time.should eq Time.local(2006, 8, 16, 3)
    time = parse_now("today at 03:00:00", hours24: true)
    time.should eq Time.local(2006, 8, 16, 3)
    time = parse_now("tomorrow at 4a.m.")
    time.should eq Time.local(2006, 8, 17, 4)
  end

  it("handle r g r") { nil }
  it("handle srp") { nil }
  it("handle s r p") { nil }
  it("handle p s r") { nil }

  it("handle s r p a") do
    time1 = parse_now("two days ago 0:0:0am")
    time2 = parse_now("two days ago 00:00:00am")
    time2.should eq time1
  end

  it("handle orr") do
    time = parse_now("5th tuesday in january")
    time.should eq Time.local(2007, 1, 30, 12)
    expect_raises(Cronic::InvalidParseError) {
      parse_now("5th tuesday in february")
    }

    {"jan" => 1, "may" => 5, "july" => 7, "aug" => 8, "oct" => 10}.each do |month, month_num|
      time = parse_now("5th tuesday in #{month}").month.should eq month_num
    end

    ["feb", "march", "april", "june", "sep", "nov", "dec"].each do |month|
      expect_raises(Cronic::InvalidParseError) {
        time = parse_now("5th tuesday in #{month}")
      }
    end
  end
  it("handle o r s r") do
    time = parse_now("3rd wednesday in november")
    time.should eq Time.local(2006, 11, 15, 12)
    expect_raises(Cronic::InvalidParseError) {
      parse_now("10th wednesday in november")
    }
  end
  it "parses ScalarMonth-RepeaterMonthName-ScalarYear(2-digit)" do
    time = parse_now("30-Mar-11")
    time.should eq Time.local(2011, 3, 30, 12)
    time = parse_now("31-Aug-12")
    time.should eq Time.local(2012, 8, 31)
  end

  describe "single Repeater" do
    it "parses a DayName" do
      time = parse_now("friday")
      time.should eq Time.local(2006, 8, 18, 12)
      time = parse_now("tue")
      time.should eq Time.local(2006, 8, 22, 12)
    end
    it "parses an hour" do
      time = parse_now("5")
      time.should eq Time.local(2006, 8, 16, 17)
      time = Cronic.parse("5", now: Time.local(2006, 8, 16, 3, 0, 0), ambiguous_time_range: nil)
      time.should eq Time.local(2006, 8, 16, 5)
    end
    it "parses a time within a day" do
      time = parse_now("13:00")
      time.should eq Time.local(2006, 8, 17, 13)
      time = parse_now("13:45")
      time.should eq Time.local(2006, 8, 17, 13, 45)
      time = parse_now("1:01pm")
      time.should eq Time.local(2006, 8, 16, 13, 1)
      time = parse_now("2:01pm")
      time.should eq Time.local(2006, 8, 16, 14, 1)
    end
    it "parses a month" do
      time = parse_now("november")
      time.should eq Time.local(2006, 11, 16)
    end
  end
  describe "double Repeater" do
    it "parses day and time" do
      time = parse_now("friday 13:00")
      time.should eq Time.local(2006, 8, 18, 13)
      time = parse_now("monday 4:00")
      time.should eq Time.local(2006, 8, 21, 16)
      time = parse_now("sat 4:00", ambiguous_time_range: nil)
      time.should eq Time.local(2006, 8, 19, 4)
      time = parse_now("sunday 4:20", ambiguous_time_range: nil)
      time.should eq Time.local(2006, 8, 20, 4, 20)
    end
    it "parses time with am/pm" do
      time = parse_now("4 pm")
      time.should eq Time.local(2006, 8, 16, 16)
      time = parse_now("4 am", ambiguous_time_range: nil)
      time.should eq Time.local(2006, 8, 16, 4)
      time = parse_now("12 pm")
      time.should eq Time.local(2006, 8, 16, 12)
      time = parse_now("12:01 pm")
      time.should eq Time.local(2006, 8, 16, 12, 1)
      time = parse_now("12:01 am")
      time.should eq Time.local(2006, 8, 16, 0, 1)
      time = parse_now("12 am")
      time.should eq Time.local(2006, 8, 16)
      time = parse_now("4:00 in the morning")
      time.should eq Time.local(2006, 8, 16, 4)
      time = parse_now("0:10")
      time.should eq Time.local(2006, 8, 17, 0, 10)
    end
    it "parses month and day" do
      time = parse_now("november 4")
      time.should eq Time.local(2006, 11, 4, 12)
      time = parse_now("aug 24")
      time.should eq Time.local(2006, 8, 24, 12)
    end
  end
  it("parse guess rrr") do
    time = parse_now("friday 1 pm")
    time.should eq Time.local(2006, 8, 18, 13)
    time = parse_now("friday 11 at night")
    time.should eq Time.local(2006, 8, 18, 23)
    time = parse_now("friday 11 in the evening")
    time.should eq Time.local(2006, 8, 18, 23)
    time = parse_now("sunday 6am")
    time.should eq Time.local(2006, 8, 20, 6)
    time = parse_now("friday evening at 7")
    time.should eq Time.local(2006, 8, 18, 19)
  end
  describe "Grabber Repeater" do
    it "parses this/next __" do
      time = parse_now_span("this year")
      time.begin.should eq Time.local(2006, 8, 17)
      time = parse_now_span("this year", context: Cronic::PointerDir::Past)
      time.begin.should eq Time.local(2006, 1, 1)
      time = parse_now("this month")
      time.should eq Time.local(2006, 8, 24, 12)
      time = parse_now("this month", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 8, 12)
      time = Cronic.parse("next month", now: Time.local(2006, 11, 15))
      time.should eq Time.local(2006, 12, 16, 12)
      time = parse_now("last november")
      time.should eq Time.local(2005, 11, 16)
      time = parse_now("this fortnight")
      time.should eq Time.local(2006, 8, 21, 19, 30)
      time = parse_now("this fortnight", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 14, 19)
      time = parse_now("this week")
      time.should eq Time.local(2006, 8, 18, 7, 30)
      time = parse_now("this week", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 14, 19)
      time = parse_now("this week", context: Cronic::PointerDir::Past, guess: Cronic::Guess::Begin)
      time.should eq Time.local(2006, 8, 13)
    end

    it "parses this week with nondefault week_start" do
      time = parse_now("this week", context: Cronic::PointerDir::Past, guess: Cronic::Guess::Begin, week_start: Time::DayOfWeek::Monday)
      time.should eq Time.local(2006, 8, 14)
    end

    it "parses this/last __" do
      time = parse_now("this weekend")
      time.should eq Time.local(2006, 8, 20)
      time = parse_now("this weekend", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 13)
      time = parse_now("last weekend")
      time.should eq Time.local(2006, 8, 13)
      time = parse_now("this day")
      time.should eq Time.local(2006, 8, 16, 19)
      time = parse_now("this day", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 16, 7)
    end
    it "parses yesterday/today/tomorrow" do
      time = parse_now("today")
      time.should eq Time.local(2006, 8, 16, 19)
      time = parse_now("yesterday")
      time.should eq Time.local(2006, 8, 15, 12)
      now = Time.parse("2011-05-27 23:10", "%Y-%m-%d %H:%M", Time::Location::UTC)
      time = Cronic.parse("yesterday", now: now)
      time.should eq Time.local(2011, 5, 26, 12)
      time = parse_now("tomorrow")
      time.should eq Time.local(2006, 8, 17, 12)
    end
    it "parses this/next/last dayname" do
      time = parse_now("this tuesday")
      time.should eq Time.local(2006, 8, 22, 12)
      time = parse_now("next tuesday")
      time.should eq Time.local(2006, 8, 22, 12)
      time = parse_now("last tuesday")
      time.should eq Time.local(2006, 8, 15, 12)
      time = parse_now("this wed")
      time.should eq Time.local(2006, 8, 23, 12)
      time = parse_now("next wed")
      time.should eq Time.local(2006, 8, 23, 12)
      time = parse_now("last wed")
      time.should eq Time.local(2006, 8, 9, 12)
    end
    it "parses possibly misspelled daynames" do
      monday = Time.local(2006, 8, 21, 12)
      parse_now("mon").should eq monday
      parse_now("mun").should eq monday
      tuesday = Time.local(2006, 8, 22, 12)
      parse_now("tue").should eq tuesday
      parse_now("tus").should eq tuesday
      wednesday = Time.local(2006, 8, 23, 12)
      parse_now("wed").should eq wednesday
      parse_now("wenns").should eq wednesday
      thursday = Time.local(2006, 8, 17, 12)
      parse_now("thu").should eq thursday
      parse_now("thur").should eq thursday
      friday = Time.local(2006, 8, 18, 12)
      parse_now("fri").should eq friday
      parse_now("fry").should eq friday
      saturday = Time.local(2006, 8, 19, 12)
      parse_now("sat").should eq saturday
      parse_now("satterday").should eq saturday
      sunday = Time.local(2006, 8, 20, 12)
      parse_now("sun").should eq sunday
      parse_now("sum").should eq sunday
    end
    it "parses portions of a day or hour/min/sec" do
      time = parse_now("this morning")
      time.should eq Time.local(2006, 8, 16, 9)
      time = parse_now("tonight")
      time.should eq Time.local(2006, 8, 16, 22)
      time = parse_now("next hr")
      time.should eq Time.local(2006, 8, 16, 15, 30, 0)
      time = parse_now("next hrs")
      time.should eq Time.local(2006, 8, 16, 15, 30, 0)
      time = parse_now("next min")
      time.should eq Time.local(2006, 8, 16, 14, 1, 30)
      time = parse_now("next mins")
      time.should eq Time.local(2006, 8, 16, 14, 1, 30)
      time = parse_now("next minute")
      time.should eq Time.local(2006, 8, 16, 14, 1, 30)
      time = parse_now("next sec")
      time.should eq Time.local(2006, 8, 16, 14, 0, 1)
      time = parse_now("next secs")
      time.should eq Time.local(2006, 8, 16, 14, 0, 1)
    end
    it "parses second as a time-unit and not 2nd" do
      time = parse_now("this second")
      time.should eq Time.local(2006, 8, 16, 14)
      time = parse_now("this second", context: Cronic::PointerDir::Past)
      time.should eq Time.local(2006, 8, 16, 14)
      time = parse_now("next second")
      time.should eq Time.local(2006, 8, 16, 14, 0, 1)
      time = parse_now("last second")
      time.should eq Time.local(2006, 8, 16, 13, 59, 59)
    end
  end

  it("parse guess grr") do
    time = parse_now("today at 9:00")
    time.should eq Time.local(2006, 8, 16, 9)
    time = parse_now("today at 2100")
    time.should eq Time.local(2006, 8, 16, 21)
    time = parse_now("this day at 0900")
    time.should eq Time.local(2006, 8, 16, 9)
    time = parse_now("tomorrow at 0900")
    time.should eq Time.local(2006, 8, 17, 9)
    time = parse_now("yesterday at 4:00")
    time.should eq Time.local(2006, 8, 15, 16)
    time = parse_now("yesterday at 4:00", ambiguous_time_range: nil)
    time.should eq Time.local(2006, 8, 15, 4)
    time = parse_now("last friday at 4:00")
    time.should eq Time.local(2006, 8, 11, 16)
    time = parse_now("next wed 4:00")
    time.should eq Time.local(2006, 8, 23, 16)
    time = parse_now("yesterday afternoon")
    time.should eq Time.local(2006, 8, 15, 15)
    time = parse_now("last week tuesday")
    time.should eq Time.local(2006, 8, 8, 12)
    time = parse_now("tonight at 7")
    time.should eq Time.local(2006, 8, 16, 19)
    time = parse_now("tonight 7")
    time.should eq Time.local(2006, 8, 16, 19)
    time = parse_now("7 tonight")
    time.should eq Time.local(2006, 8, 16, 19)
  end
  it("parse guess grrr") do
    time = parse_now("today at 6:00pm")
    time.should eq Time.local(2006, 8, 16, 18)
    time = parse_now("today at 6:00am")
    time.should eq Time.local(2006, 8, 16, 6)
    time = parse_now("this day 1800")
    time.should eq Time.local(2006, 8, 16, 18)
    time = parse_now("yesterday at 4:00pm")
    time.should eq Time.local(2006, 8, 15, 16)
    time = parse_now("tomorrow evening at 7")
    time.should eq Time.local(2006, 8, 17, 19)
    time = parse_now("tomorrow morning at 5:30")
    time.should eq Time.local(2006, 8, 17, 5, 30)
    time = parse_now("next monday at 12:01 am")
    time.should eq Time.local(2006, 8, 21, 0, 1)
    time = parse_now("next monday at 12:01 pm")
    time.should eq Time.local(2006, 8, 21, 12, 1)
    time = parse_now("sunday at 8:15pm", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2006, 8, 13, 20, 15)
  end

  it("parse guess rgr") do
    time = parse_now("afternoon yesterday")
    time.should eq Time.local(2006, 8, 15, 15)
    time = parse_now("tuesday last week")
    time.should eq Time.local(2006, 8, 8, 12)
  end

  describe "Scalar-Repeater-Pointer" do
    it "parses a/an ago" do
      time = parse_now("AN hour ago")
      time.should eq Time.local(2006, 8, 16, 13)
      time = parse_now("A day ago")
      time.should eq Time.local(2006, 8, 15, 14)
      time = parse_now("a month ago")
      time.should eq Time.local(2006, 7, 16, 14)
      time = parse_now("a year ago")
      time.should eq Time.local(2005, 8, 16, 14)
    end

    it "parses ago" do
      time = parse_now("3 years ago")
      time.should eq Time.local(2003, 8, 16, 14)
      time = parse_now("1 month ago")
      time.should eq Time.local(2006, 7, 16, 14)
      time = parse_now("1 fortnight ago")
      time.should eq Time.local(2006, 8, 2, 14)
      time = parse_now("2 fortnights ago")
      time.should eq Time.local(2006, 7, 19, 14)
      time = parse_now("3 weeks ago")
      time.should eq Time.local(2006, 7, 26, 14)
      time = parse_now("2 weekends ago")
      time.should eq Time.local(2006, 8, 5)
      time = parse_now("3 days ago")
      time.should eq Time.local(2006, 8, 13, 14)
      time = parse_now("5 mornings ago")
      time.should eq Time.local(2006, 8, 12, 9)
      time = parse_now("7 hours ago")
      time.should eq Time.local(2006, 8, 16, 7)
      time = parse_now("3 minutes ago")
      time.should eq Time.local(2006, 8, 16, 13, 57)
    end
    it "parses before now" do
      time = parse_now("20 seconds before now")
      time.should eq Time.local(2006, 8, 16, 13, 59, 40)
    end

    it "parses from now" do
      time = parse_now("3 years from now")
      time.should eq Time.local(2009, 8, 16, 14, 0, 0)
      time = parse_now("1 week from now")
      time.should eq Time.local(2006, 8, 23, 14, 0, 0)
      time = parse_now("1 weekend from now")
      time.should eq Time.local(2006, 8, 19)
      time = parse_now("2 weekends from now")
      time.should eq Time.local(2006, 8, 26)
      time = parse_now("1 hour from now")
      time.should eq Time.local(2006, 8, 16, 15)
      time = parse_now("20 seconds from now")
      time.should eq Time.local(2006, 8, 16, 14, 0, 20)
    end

    it "parses in a/an __" do
      # per Chronic.rb issue #384
      time = parse_now("in a week")
      time.should eq Time.local(2006, 8, 23, 14, 0, 0)
      time = parse_now("in a day")
      time.should eq Time.local(2006, 8, 17, 14, 0, 0)
      time = parse_now("in an hour")
      time.should eq Time.local(2006, 8, 16, 15, 0, 0)
    end
    
    it "parses hence" do
      time = parse_now("6 months hence")
      time.should eq Time.local(2007, 2, 16, 14)
      time = parse_now("3 fortnights hence")
      time.should eq Time.local(2006, 9, 27, 14)
      time = parse_now("1 day hence")
      time.should eq Time.local(2006, 8, 17, 14)
      time = parse_now("5 mornings hence")
      time.should eq Time.local(2006, 8, 21, 9)
      time = parse_now("20 minutes hence")
      time.should eq Time.local(2006, 8, 16, 14, 20)
    end


    it "parses more complex clauses" do
      time = Cronic.parse("2 months ago", now: Time.parse("2007-03-07 23:30", "%Y-%m-%d %H:%M", Time::Location::UTC))
      time.should eq Time.local(2007, 1, 7, 23, 30)
      time = parse_now("25 minutes and 20 seconds from now")
      time.should eq Time.local(2006, 8, 16, 14, 25, 20)
      time = parse_now("24 hours and 20 minutes from now")
      time.should eq Time.local(2006, 8, 17, 14, 20, 0)
      time = parse_now("24 hours 20 minutes from now")
      time.should eq Time.local(2006, 8, 17, 14, 20, 0)
    end
    
    pending "doesnt parse this case from Cronic.rb #281" do
      time = parse_now("24 hours and 20 minutes ago")
      time.should eq Time.local(2006, 8, 15, 13, 40, 0)
    end
    
  end

  it("parse guess p s r") do
    time = parse_now("in 3 hours")
    time.should eq Time.local(2006, 8, 16, 17)
  end

  it("parse guess s r p a") do
    time = parse_now("3 years ago tomorrow")
    time.should eq Time.local(2003, 8, 17, 12)
    time = parse_now("3 years ago this friday")
    time.should eq Time.local(2003, 8, 18, 12)
    time = parse_now("3 months ago saturday at 5:00 pm")
    time.should eq Time.local(2006, 5, 19, 17)
    time = parse_now("2 days from this second")
    time.should eq Time.local(2006, 8, 18, 14)
    time = parse_now("7 hours before tomorrow at midnight")
    time.should eq Time.local(2006, 8, 17, 17)
  end

  it("parse guess rmn s r p") do
    time = parse_now("september 3 years ago", guess: Cronic::Guess::Begin)
    time.should eq Time.local(2003, 9, 1)
  end

  describe "Ordinal Repeater Grabber Repeater" do
    it "parses nth __ next __" do
      time = parse_now_span("3rd month next year")
      time.begin.should eq Time.local(2007, 3, 1)
      time = parse_now("3rd thursday this september")
      time.should eq Time.local(2006, 9, 21, 12)
    end

    it "parses nth weekday this month" do
      now = Time.parse("01/10/2010", "%d/%m/%Y", Time::Location::UTC)
      time = Cronic.parse("3rd thursday this november", now: now)
      time.should eq Time.local(2010, 11, 18, 12)
    end

    it "parses nth day last week" do
      time = parse_now("4th day last week")
      time.should eq Time.local(2006, 8, 9, 12)
    end
  end

  it("parse guess nonsense") do
    expect_raises(Cronic::UnknownParseError) { parse_now("some stupid nonsense") }
    expect_raises(Cronic::UnknownParseError) { parse_now("Ham Sandwich") }
    expect_raises(Cronic::UnknownParseError) { parse_now("t") }
  end

  it("parse span") do
    span = parse_now_span("friday")
    span.begin.should eq Time.local(2006, 8, 18)
    span.end.should eq Time.local(2006, 8, 19)
    span = parse_now_span("november")
    span.begin.should eq Time.local(2006, 11, 1)
    span.end.should eq Time.local(2006, 12, 1)
    span = Cronic.parse_span("weekend", now: (TIME_2006_08_16_14_00_00))
    span.begin.should eq Time.local(2006, 8, 19)
    span.end.should eq Time.local(2006, 8, 21)
  end
  it("parse with endian precedence") do
    date = "11/02/2007"
    expect_for_middle_endian = Time.local(2007, 11, 2, 12)
    expect_for_little_endian = Time.local(2007, 2, 11, 12)
    Cronic.parse(date).should eq expect_for_middle_endian
    Cronic.parse(date, endian_precedence: ([DateEndian::MonthDay, DateEndian::DayMonth])).should eq expect_for_middle_endian
    Cronic.parse(date, endian_precedence: ([DateEndian::DayMonth, DateEndian::MonthDay])).should eq expect_for_little_endian
  end

  it("parse words") do
    parse_now("thirty-three days from now").should eq parse_now("33 days from now")
    parse_now("two million eight hundred and sixty seven thousand five hundred and thirty two seconds from now").should eq parse_now("2867532 seconds from now")
    parse_now("may tenth").should eq parse_now("may 10th")
    parse_now("2nd monday in january").should eq parse_now("second monday in january")
  end

  it "parses relative to an hour before" do
    parse_now("10 to 2").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("10 till 2").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("10 prior to 2").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("10 before 2").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("10 to").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("10 till").should eq Time.local(2006, 8, 16, 13, 50)
    parse_now("quarter to 4").should eq Time.local(2006, 8, 16, 15, 45)
  end

  it "parses relative to an hour after" do
    parse_now("10 after 2").should eq Time.local(2006, 8, 16, 14, 10)
    parse_now("10 past 2").should eq Time.local(2006, 8, 16, 14, 10)
    parse_now("half past 2").should eq Time.local(2006, 8, 16, 14, 30)
  end

  pending "parses relative to a date after from Chronic.rb #382" do
    # failing test submitted for Chronic.rb #382
    time = parse_now("five years after 11 May 2017")
    time.should eq Time.local(2023, 7, 2, 17, 30)
  end
  
  it "parses only complete pointers" do
    parse_now("eat pasty buns today at 2pm").should eq TIME_2006_08_16_14_00_00
    parse_now("futuristically speaking today at 2pm").should eq TIME_2006_08_16_14_00_00
    parse_now("meeting today at 2pm").should eq TIME_2006_08_16_14_00_00
  end

  it("am pm") do
    parse_now("8/16/2006 at 12am").should eq Time.local(2006, 8, 16)
    parse_now("8/16/2006 at 12pm").should eq Time.local(2006, 8, 16, 12)
  end

  it("a p") do
    parse_now("8/16/2006 at 12:15a").should eq Time.local(2006, 8, 16, 0, 15)
    parse_now("8/16/2006 at 6:30p").should eq Time.local(2006, 8, 16, 18, 30)
  end

  it("seasons") do
    t = parse_now_span("this spring")
    t.begin.should eq Time.local(2007, 3, 20)
    t.end.should eq Time.local(2007, 6, 20)
    t = parse_now_span("this winter")
    t.begin.should eq Time.local(2006, 12, 22)
    t.end.should eq Time.local(2007, 3, 19)
    t = parse_now_span("last spring")
    t.begin.should eq Time.local(2006, 3, 20)
    t.end.should eq Time.local(2006, 6, 20)
    t = parse_now_span("last winter")
    t.begin.should eq Time.local(2005, 12, 22)
    t.end.should eq Time.local(2006, 3, 19)
    t = parse_now_span("next spring")
    t.begin.should eq Time.local(2007, 3, 20)
    t.end.should eq Time.local(2007, 6, 20)
  end
  it("quarters") do
    time = parse_now_span("this quarter")
    time.begin.should eq Time.local(2006, 7, 1)
    time.end.should eq Time.local(2006, 10, 1)
    time = parse_now_span("next quarter")
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
    time = parse_now_span("last quarter")
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
  end
  it("quarters srp") do
    time = parse_now_span("1 quarter ago")
    time.begin.should eq Time.local(2006, 4, 1)
    time.end.should eq Time.local(2006, 7, 1)
    time = parse_now_span("2 quarters ago")
    time.begin.should eq Time.local(2006, 1, 1)
    time.end.should eq Time.local(2006, 4, 1)
    time = parse_now_span("1 quarter from now")
    time.begin.should eq Time.local(2006, 10, 1)
    time.end.should eq Time.local(2007, 1, 1)
  end
  it("quarters named") do
    ["Q1", "first quarter", "1st quarter"].each do |string|
      time = parse_now_span(string, context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Future)
      time.begin.should eq Time.local(2007, 1, 1)
      time.end.should eq Time.local(2007, 4, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Past)
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span("#{string} 2005")
      time.begin.should eq Time.local(2005, 1, 1)
      time.end.should eq Time.local(2005, 4, 1)
      time = parse_now_span("2005 #{string}")
      time.begin.should eq Time.local(2005, 1, 1)
      time.end.should eq Time.local(2005, 4, 1)
      time = parse_now_span("#{string} this year")
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span("this year #{string}")
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span("#{string} next year")
      time.begin.should eq Time.local(2007, 1, 1)
      time.end.should eq Time.local(2007, 4, 1)
      time = parse_now_span("next year #{string}")
      time.begin.should eq Time.local(2007, 1, 1)
      time.end.should eq Time.local(2007, 4, 1)
      time = parse_now_span("this #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span("last #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 1, 1)
      time.end.should eq Time.local(2006, 4, 1)
      time = parse_now_span("next #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2007, 1, 1)
      time.end.should eq Time.local(2007, 4, 1)
    end
    ["Q2", "second quarter", "2nd quarter"].each do |string|
      time = parse_now_span(string, context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Future)
      time.begin.should eq Time.local(2007, 4, 1)
      time.end.should eq Time.local(2007, 7, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Past)
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span("#{string} 2005")
      time.begin.should eq Time.local(2005, 4, 1)
      time.end.should eq Time.local(2005, 7, 1)
      time = parse_now_span("2005 #{string}")
      time.begin.should eq Time.local(2005, 4, 1)
      time.end.should eq Time.local(2005, 7, 1)
      time = parse_now_span("#{string} this year")
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span("this year #{string}")
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span("#{string} next year")
      time.begin.should eq Time.local(2007, 4, 1)
      time.end.should eq Time.local(2007, 7, 1)
      time = parse_now_span("next year #{string}")
      time.begin.should eq Time.local(2007, 4, 1)
      time.end.should eq Time.local(2007, 7, 1)
      time = parse_now_span("this #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span("last #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 4, 1)
      time.end.should eq Time.local(2006, 7, 1)
      time = parse_now_span("next #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2007, 4, 1)
      time.end.should eq Time.local(2007, 7, 1)
    end
    ["Q3", "third quarter", "3rd quarter"].each do |string|
      time = parse_now_span(string, context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 7, 1)
      time.end.should eq Time.local(2006, 10, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Future)
      time.begin.should eq Time.local(2007, 7, 1)
      time.end.should eq Time.local(2007, 10, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Past)
      time.begin.should eq Time.local(2005, 7, 1)
      time.end.should eq Time.local(2005, 10, 1)
      time = parse_now_span("#{string} 2005")
      time.begin.should eq Time.local(2005, 7, 1)
      time.end.should eq Time.local(2005, 10, 1)
      time = parse_now_span("2005 #{string}")
      time.begin.should eq Time.local(2005, 7, 1)
      time.end.should eq Time.local(2005, 10, 1)
      time = parse_now_span("#{string} this year")
      time.begin.should eq Time.local(2006, 7, 1)
      time.end.should eq Time.local(2006, 10, 1)
      time = parse_now_span("this year #{string}")
      time.begin.should eq Time.local(2006, 7, 1)
      time.end.should eq Time.local(2006, 10, 1)
      time = parse_now_span("#{string} next year")
      time.begin.should eq Time.local(2007, 7, 1)
      time.end.should eq Time.local(2007, 10, 1)
      time = parse_now_span("next year #{string}")
      time.begin.should eq Time.local(2007, 7, 1)
      time.end.should eq Time.local(2007, 10, 1)
      time = parse_now_span("this #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 7, 1)
      time.end.should eq Time.local(2006, 10, 1)
      time = parse_now_span("last #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2005, 7, 1)
      time.end.should eq Time.local(2005, 10, 1)
      time = parse_now_span("next #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2007, 7, 1)
      time.end.should eq Time.local(2007, 10, 1)
    end
    ["Q4", "fourth quarter", "4th quarter"].each do |string|
      time = parse_now_span(string, context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Future)
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
      time = parse_now_span(string, context: Cronic::PointerDir::Past)
      time.begin.should eq Time.local(2005, 10, 1)
      time.end.should eq Time.local(2006, 1, 1)
      time = parse_now_span("#{string} 2005")
      time.begin.should eq Time.local(2005, 10, 1)
      time.end.should eq Time.local(2006, 1, 1)
      time = parse_now_span("2005 #{string}")
      time.begin.should eq Time.local(2005, 10, 1)
      time.end.should eq Time.local(2006, 1, 1)
      time = parse_now_span("#{string} this year")
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
      time = parse_now_span("this year #{string}")
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
      time = parse_now_span("#{string} next year")
      time.begin.should eq Time.local(2007, 10, 1)
      time.end.should eq Time.local(2008, 1, 1)
      time = parse_now_span("next year #{string}")
      time.begin.should eq Time.local(2007, 10, 1)
      time.end.should eq Time.local(2008, 1, 1)
      time = parse_now_span("this #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
      time = parse_now_span("last #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2005, 10, 1)
      time.end.should eq Time.local(2006, 1, 1)
      time = parse_now_span("next #{string}", context: Cronic::PointerDir::None)
      time.begin.should eq Time.local(2006, 10, 1)
      time.end.should eq Time.local(2007, 1, 1)
    end
  end
  it("days in november") do
    t1 = Cronic.parse("1st thursday in november", now: Time.local(2007, 1, 1))
    t1.should eq Time.local(2007, 11, 1, 12)
    t1 = Cronic.parse("1st friday in november", now: Time.local(2007, 1, 1))
    t1.should eq Time.local(2007, 11, 2, 12)
    t1 = Cronic.parse("1st saturday in november", now: Time.local(2007, 1, 1))
    t1.should eq Time.local(2007, 11, 3, 12)
  end
  pending "days in november around daylight savings" do
    t1 = Cronic.parse("1st sunday in november", now: Time.local(2007, 1, 1))
    t1.should eq Time.local(2007, 11, 4, 12)
    t1 = Cronic.parse("1st monday in november", now: Time.local(2007, 1, 1))
    t1.should eq Time.local(2007, 11, 5, 12)
  end
  it("now changes") do
    t1 = Cronic.parse("now")
    sleep(0.1)
    t2 = Cronic.parse("now")
    t2.should_not eq t1
  end
  it("noon") do
    t1 = Cronic.parse("2011-01-01 at noon", ambiguous_time_range: nil)
    t1.should eq Time.local(2011, 1, 1, 12, 0)
  end
  it("handle rdn rmn sd") do
    time = parse_now("Thu Aug 10")
    time.should eq Time.local(2006, 8, 10, 12)
    time = parse_now("Thursday July 31")
    time.should eq Time.local(2006, 7, 31, 12)
    time = parse_now("Thursday December 31")
    time.should eq Time.local(2006, 12, 31, 12)
  end
  it("handle rdn rmn sd rt") do
    time = parse_now("Thu Aug 10 4pm")
    time.should eq Time.local(2006, 8, 10, 16)
    time = parse_now("Thu Aug 10 at 4pm")
    time.should eq Time.local(2006, 8, 10, 16)
  end
  it("handle rdn rmn od rt") do
    time = parse_now("Thu Aug 10th at 4pm")
    time.should eq Time.local(2006, 8, 10, 16)
  end
  it("handle rdn od rt") do
    time = parse_now("Thu 17th at 4pm")
    time.should eq Time.local(2006, 8, 17, 16)
    time = parse_now("Thu 16th at 4pm")
    time.should eq Time.local(2006, 8, 16, 16)
    time = parse_now("Thu 1st at 4pm")
    time.should eq Time.local(2006, 9, 1, 16)
    time = parse_now("Thu 1st at 4pm", context: Cronic::PointerDir::Past)
    time.should eq Time.local(2006, 8, 1, 16)
  end
  it("handle rdn od") do
    time = parse_now("Thu 17th")
    time.should eq Time.local(2006, 8, 17, 12)
  end
  it("handle rdn rmn sd sy") do
    time = parse_now("Thu Aug 10 2006")
    time.should eq Time.local(2006, 8, 10, 12)
    time = parse_now("Thursday July 31 2006")
    time.should eq Time.local(2006, 7, 31, 12)
    time = parse_now("Thursday December 31 2006")
    time.should eq Time.local(2006, 12, 31, 12)
    time = parse_now("Thursday December 30 2006")
    time.should eq Time.local(2006, 12, 30, 12)
  end
  it("handle rdn rmn od") do
    time = parse_now("Thu Aug 10th")
    time.should eq Time.local(2006, 8, 10, 12)
    time = parse_now("Thursday July 31st")
    time.should eq Time.local(2006, 7, 31, 12)
    time = parse_now("Thursday December 31st")
    time.should eq Time.local(2006, 12, 31, 12)
  end
  it("handle rdn rmn od sy") do
    time = parse_now("Wed Aug 10th 2005")
    time.should eq Time.local(2005, 8, 10, 12)
    time = parse_now("Sun July 31st 2005")
    time.should eq Time.local(2005, 7, 31, 12)
    time = parse_now("Sat December 31st 2005")
    time.should eq Time.local(2005, 12, 31, 12)
    time = parse_now("Fri December 30th 2005")
    time.should eq Time.local(2005, 12, 30, 12)
  end
  it("normalizing day portions") do
    pre_normalize("8:00 p.m. February 11").should eq pre_normalize("8:00 pm February 11")
  end
  it("normalizing time of day phrases") do
    pre_normalize("12:00 p.m. February 11").should eq pre_normalize("midday February 11")
  end
end
