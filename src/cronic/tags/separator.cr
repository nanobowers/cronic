module Cronic
  class Separator < Tag
    # Scan an Array of Token objects and apply any necessary Separator
    # tags to each token.
    def self.scan(tokens : Array(Token), **options) : Void
      tokens.each do |token|
        token.tag scan_for(token, SeparatorComma, {:"," => :comma})
        token.tag scan_for(token, SeparatorDot, {:"." => :dot})
        token.tag scan_for(token, SeparatorColon, {:":" => :colon})
        token.tag scan_for(token, SeparatorSpace, {:" " => :space})
        token.tag scan_for(token, SeparatorSlash, {:"/" => :slash})
        token.tag scan_for(token, SeparatorDash, {:- => :dash})
        token.tag scan_for(token, SeparatorAt, {/^(at|@)$/i => :at})
        token.tag scan_for(token, SeparatorIn, {"in" => :in})
        token.tag scan_for(token, SeparatorOn, {"on" => :on})
        token.tag scan_for(token, SeparatorAnd, {"and" => :and})
        token.tag scan_for(token, SeparatorT, {:T => :T})
        token.tag scan_for(token, SeparatorW, {:W => :W})
        token.tag scan_for_quote(token)
      end
    end

    # token - The Token object we want to scan.
    def self.scan_for_quote(token : Token) : SeparatorQuote?
      scan_for(token, SeparatorQuote, {'\'' => :single_quote, '"' => :double_quote})
    end

    def to_s
      "separator"
    end
  end

  # :nodoc:
  class SeparatorComma < Separator
    def to_s
      super + "-comma"
    end
  end

  # :nodoc:
  class SeparatorDot < Separator
    def to_s
      super + "-dot"
    end
  end

  # :nodoc:
  class SeparatorColon < Separator
    def to_s
      super + "-colon"
    end
  end

  # :nodoc:
  class SeparatorSpace < Separator
    def to_s
      super + "-space"
    end
  end

  # :nodoc:
  class SeparatorSlash < Separator
    def to_s
      super + "-slash"
    end
  end

  # :nodoc:
  class SeparatorDash < Separator
    def to_s
      super + "-dash"
    end
  end

  # :nodoc:
  class SeparatorQuote < Separator
    def to_s
      super + "-quote-" + @type.to_s
    end
  end

  # :nodoc:
  class SeparatorAt < Separator
    def to_s
      super + "-at"
    end
  end

  # :nodoc:
  class SeparatorIn < Separator
    def to_s
      super + "-in"
    end
  end

  # :nodoc:
  class SeparatorOn < Separator
    def to_s
      super + "-on"
    end
  end

  # :nodoc:
  class SeparatorAnd < Separator
    def to_s
      super + "-and"
    end
  end

  # :nodoc:
  class SeparatorT < Separator
    def to_s
      super + "-T"
    end
  end

  # :nodoc:
  class SeparatorW < Separator
    def to_s
      super + "-W"
    end
  end
end
