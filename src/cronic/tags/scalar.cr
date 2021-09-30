module Cronic
  class Scalar < Tag
    DAY_PORTIONS = %w(am pm morning afternoon evening night)

    # Scan an Array of Token objects and apply any necessary Scalar
    # tags to each token.
    def self.scan(tokens : Array(Token),
                  hours24 : Bool? = nil,
                  ambiguous_year_future_bias : Int32 = 50,
                  **options) : Void
      tokens.each_index do |i|
        token = tokens[i]
        post_token = tokens[i + 1]?
        if token.word =~ /^\d+$/
          width = token.word.size
          scalar = token.word.to_i
          token.tag(Scalar.new(scalar, width))
          token.tag(ScalarWide.new(token.word, width)) if width == 4
          token.tag(ScalarSubsecond.new(scalar, width)) if Cronic::TimeUtil.could_be_subsecond?(scalar, width)
          token.tag(ScalarSecond.new(scalar, width)) if Cronic::TimeUtil.could_be_second?(scalar, width)
          token.tag(ScalarMinute.new(scalar, width)) if Cronic::TimeUtil.could_be_minute?(scalar, width)
          token.tag(ScalarHour.new(scalar, width)) if Cronic::TimeUtil.could_be_hour?(scalar, width, hours24 == false)
          unless post_token && DAY_PORTIONS.includes?(post_token.word)
            token.tag(ScalarDay.new(scalar, width)) if Cronic::Date.could_be_day?(scalar, width)
            token.tag(ScalarMonth.new(scalar, width)) if Cronic::Date.could_be_month?(scalar, width)
            if Cronic::Date.could_be_year?(scalar, width)
              year = Cronic::Date.make_year(scalar, ambiguous_year_future_bias)
              token.tag(ScalarYear.new(year.to_i, width))
            end
          end
        end
      end
    end

    def to_s
      "scalar"
    end
  end

  # :nodoc:
  class ScalarWide < Scalar
    def to_s
      super + "-wide-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarSubsecond < Scalar
    def to_s
      super + "-subsecond-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarSecond < Scalar
    def to_s
      super + "-second-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarMinute < Scalar
    def to_s
      super + "-minute-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarHour < Scalar
    def to_s
      super + "-hour-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarDay < Scalar
    def to_s
      super + "-day-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarMonth < Scalar
    def to_s
      super + "-month-" + @type.to_s
    end
  end

  # :nodoc:
  class ScalarYear < Scalar
    def to_s
      super + "-year-" + @type.to_s
    end
  end
end
