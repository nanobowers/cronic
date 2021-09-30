module Cronic
  # :nodoc:
  class Tick
    property :time
    getter? :ambiguous

    def initialize(@time : Int32 | Float64, @ambiguous = false)
    end

    def *(other)
      Tick.new(@time * other, @ambiguous)
    end

    def to_f
      @time.to_f
    end

    def to_s
      @time.to_s + (@ambiguous ? "?" : "")
    end

    def timespan : Time::Span
      @time.seconds
    end
  end

  # :nodoc:
  class RepeaterTime < Repeater
    @current_time : Time?
    @tagtype : Tick
    getter :tagtype

    def initialize(time, width = nil, @hours24 : Bool? = nil, **kwargs)
      @type = :time
      @current_time = nil
      @now = Time.local
      time_parts = time.split(":")
      raise ArgumentError.new("Time cannot have more than 4 groups of ':'") if time_parts.size > 4

      if time_parts.size == 1 && time_parts.first.size > 2
        if time_parts.first.size > 4
          second_index = time_parts.first.size - 2
          time_parts.insert(1, time_parts.first[second_index..time_parts.first.size])
          time_parts[0] = time_parts.first[0..second_index - 1]
        end
        minute_index = time_parts.first.size - 2
        time_parts.insert(1, time_parts.first[minute_index..time_parts.first.size])
        time_parts[0] = time_parts.first[0..minute_index - 1]
      end

      ambiguous = false
      hours = time_parts.first.to_i

      if @hours24.nil? || @hours24 == false
        ambiguous = true if (time_parts.first.size == 1 && hours > 0) || (hours >= 10 && hours <= 12) || (@hours24 == false && hours > 0)
        hours = 0 if hours == 12 && ambiguous
      end

      hours *= 60 * 60
      minutes = 0
      seconds = 0
      subseconds = 0

      minutes = time_parts[1].to_f.to_i * 60 if time_parts.size > 1
      seconds = time_parts[2].to_f.to_i if time_parts.size > 2
      subseconds = time_parts[3].to_f / (10 ** time_parts[3].size) if time_parts.size > 3

      @tagtype = Tick.new(hours + minutes + seconds + subseconds, ambiguous)
    end

    def update_current_time(pointer : PointerDir)
      half_day = 12.hours
      full_day = 24.hours
      midnight = Time.local(@now.year, @now.month, @now.day)
      yesterday_midnight = midnight - full_day
      tomorrow_midnight = midnight + full_day
      offset_fix = Time::Span.new(seconds: (midnight.offset - tomorrow_midnight.offset))
      tomorrow_midnight += offset_fix

      case pointer
      in PointerDir::Future, PointerDir::None
        if tagtype.ambiguous?
          [midnight + tagtype.timespan + offset_fix, midnight + half_day + tagtype.timespan + offset_fix, tomorrow_midnight + tagtype.timespan].each do |t|
            (@current_time = t; return) if t >= @now
          end
        else
          [midnight + tagtype.timespan + offset_fix, tomorrow_midnight + tagtype.timespan].each do |t|
            (@current_time = t; return) if t >= @now
          end
        end
      in PointerDir::Past
        if tagtype.ambiguous?
          [midnight + half_day + tagtype.timespan + offset_fix, midnight + tagtype.timespan + offset_fix, yesterday_midnight + tagtype.timespan + half_day].each do |t|
            (@current_time = t; return) if t <= @now
          end
        else
          [midnight + tagtype.timespan + offset_fix, yesterday_midnight + tagtype.timespan].each do |t|
            (@current_time = t; return) if t <= @now
          end
        end
      end
    end

    # Return the next past or future Span for the time that this Repeater represents
    #   pointer - which temporal direction to fetch the next day
    def next(pointer : PointerDir)
      if @current_time.nil?
        update_current_time(pointer)
        @current_time || raise RuntimeError.new("Current time cannot be nil at this point")
      else
        increment = tagtype.ambiguous? ? 12.hours : 24.hours
        @current_time = @current_time.as(Time) + increment * pointer.to_dir.value
      end
      ctime = @current_time.as(Time)
      Timespan.new(ctime, ctime + 1.second)
    end

    def this(context : PointerDir)
      self.next(context)
    end

    def width
      1
    end

    def to_s
      super + "-time-" + tagtype.to_s
    end
  end
end
