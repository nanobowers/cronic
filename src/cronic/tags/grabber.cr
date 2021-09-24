module Cronic
  enum GrabberEnum
    Last = -1
    This =  0
    Next =  1
  end

  class Grabber < Tag
    getter :grab

    def initialize(@grab : GrabberEnum, width = nil, **opts)
      super(@grab.to_s, width, **opts)
    end

    # Scan an Array of Tokens and apply any necessary Grabber tags to
    # each token.
    def self.scan(tokens : Array(Token), **options) : Void
      tokens.each do |token|
        token.tag case token.word
        when "last" then Grabber.new(GrabberEnum::Last)
        when "this" then Grabber.new(GrabberEnum::This)
        when "next" then Grabber.new(GrabberEnum::Next)
        else             nil
        end
      end
    end

    def to_s
      "grabber-" + @type.to_s
    end
  end
end
