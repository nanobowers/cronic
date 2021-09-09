module Cronic

  class Tick #:nodoc:
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

    def timespan
      ::Time::Span.new(seconds: @time.to_i)
    end
  end

  class RepeaterTime < Repeater #:nodoc:

    @current_time : ::Time?
    #@type : Tick
          
    def initialize(time, width = nil, @hours24 : Bool? = nil)
      @current_time = nil
      @now = ::Time.local
      #@options = kwargs
      time_parts = time.split(":")
      raise ArgumentError.new("Time cannot have more than 4 groups of ':'") if time_parts.size > 4

      if time_parts.first.size > 2 && time_parts.size == 1
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

      if @hours24.nil? || (!@hours24.nil? && @hours24 != true)
          ambiguous = true if (time_parts.first.size == 1 && hours > 0) || (hours >= 10 && hours <= 12) || (@hours24 == false && hours > 0)
          hours = 0 if hours == 12 && ambiguous
      end

      hours *= 60 * 60
      minutes = 0
      seconds = 0
      subseconds = 0

      minutes = time_parts[1].to_i * 60 if time_parts.size > 1
      seconds = time_parts[2].to_i if time_parts.size > 2
      subseconds = time_parts[3].to_f / (10 ** time_parts[3].size) if time_parts.size > 3

      @type = Tick.new(hours + minutes + seconds + subseconds, ambiguous)
    end
    def ticktype
      @type.as(Tick)
    end
      def update_current_time(pointer)
        half_day = ::Time::Span.new(hours: 12)
        full_day = ::Time::Span.new(hours: 24)
        midnight = ::Time.local(@now.year, @now.month, @now.day)
        yesterday_midnight = midnight - full_day
        tomorrow_midnight = midnight + full_day
        offset_fix = ::Time::Span.new(seconds: (midnight.offset - tomorrow_midnight.offset))
        tomorrow_midnight += offset_fix

        if pointer == :future
          if ticktype.ambiguous?
            [midnight + ticktype.timespan + offset_fix, midnight + half_day + ticktype.timespan + offset_fix, tomorrow_midnight + ticktype.timespan].each do |t|
              (@current_time = t; return) if t >= @now
            end
          else
            [midnight + ticktype.timespan + offset_fix, tomorrow_midnight + ticktype.timespan].each do |t|
              (@current_time = t; return) if t >= @now
            end
          end
        else # pointer == :past
          if ticktype.ambiguous?
             [midnight + half_day + ticktype.timespan + offset_fix, midnight + ticktype.timespan + offset_fix, yesterday_midnight + ticktype.timespan + half_day].each do |t|
               (@current_time = t; return) if t <= @now
             end
          else
            [midnight + ticktype.timespan + offset_fix, yesterday_midnight + ticktype.timespan].each do |t|
              (@current_time = t; return) if t <= @now
            end
          end
        end
      end
#    end
#      end
    # Return the next past or future Span for the time that this Repeater represents
    #   pointer - Symbol representing which temporal direction to fetch the next day
    #             must be either :past or :future
    def next(pointer)
      super
      
      first = false

      unless @current_time
        first = true

        update_current_time(pointer)

        @current_time || raise RuntimeError.new("Current time cannot be nil at this point")
      end
      @current_time = @current_time.as(::Time)
      unless first
        increment = ticktype.ambiguous? ? ::Time::Span.new(hours: 12) : ::Time::Span.new(hours: 24)
        @current_time = @current_time.as(::Time) + ((pointer == :future) ? increment : -increment)
      end
      ctime = @current_time.as(::Time)
      SecSpan.new(ctime, ctime + ::Time::Span.new(seconds: width))
    end

    def this(context = :future)
      super
      context = :future if context == :none
      self.next(context)
    end

    def width
      1
    end

    def to_s
      super << "-time-" << @type.to_s
    end
  end
end
