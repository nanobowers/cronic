module Cronic
  class Sign < Tag
    # Scan an Array of Token objects and apply any necessary Sign
    # tags to each token.
    def self.scan(tokens : Array(Token), **options) : Void
      tokens.each do |token|
        token.tag scan_for(token, SignPlus, {:+ => :plus})
        token.tag scan_for(token, SignMinus, {:- => :minus})
      end
    end

    def to_s
      "sign"
    end
  end

  class SignPlus < Sign
    def to_s
      super + "-plus"
    end
  end

  class SignMinus < Sign
    def to_s
      super + "-minus"
    end
  end
end
