require "../src/cronic"

describe Cronic::RepeaterMonth do
  now_time : Time
  Spec.before_suite do
    now_time = Time.local(2006, 8, 16, 14, 0, 0, 0)
  end
  
  it("offset by") do
    time = Cronic::RepeaterMonth.new(:month).offset_by(now_time, 1, :future)
    time.should eq Time.local(2006, 9, 16, 14)
    time = Cronic::RepeaterMonth.new(:month).offset_by(now_time, 5, :future)
    time.should eq Time.local(2007, 1, 16, 14)
    time = Cronic::RepeaterMonth.new(:month).offset_by(now_time, 1, :past)
    time.should eq Time.local(2006, 7, 16, 14)
    time = Cronic::RepeaterMonth.new(:month).offset_by(now_time, 10, :past)
    time.should eq Time.local(2005, 10, 16, 14)
    time = Cronic::RepeaterMonth.new(:month).offset_by(Time.local(2010, 3, 29), 1, :past)
    time.month.should eq 2
    time.day.should eq 28
  end
  it("offset") do
    span = Cronic::Span.new(now_time, (now_time + 60))
    offset_span = Cronic::RepeaterMonth.new(:month).offset(span, 1, :future)
    offset_span.begin.should eq Time.local(2006, 9, 16, 14)
    offset_span.end.should eq Time.local(2006, 9, 16, 14, 1)
    span = Cronic::Span.new(now_time, (now_time + 60))
    offset_span = Cronic::RepeaterMonth.new(:month).offset(span, 1, :past)
    offset_span.begin.should eq Time.local(2006, 7, 16, 14)
    offset_span.end.should eq Time.local(2006, 7, 16, 14, 1)
  end
end
