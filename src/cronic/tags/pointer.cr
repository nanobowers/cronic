module Cronic
  class Pointer < Tag
    # Scan an Array of Token objects and apply any necessary Pointer
    # tags to each token.
    #
    # tokens - An Array of tokens to scan.
    # options - The Hash of options specified in Cronic::parse.
    #
    # Returns an Array of tokens.
    getter :dir

    def initialize(@dir : PointerDir, width = nil, **options)
      super(@dir.to_s, width)
    end

    def self.scan(tokens, **options)
      tokens.each do |token|
        token.tag scan_for(token, self, patterns, **options)
      end
    end

    def self.patterns
      @@patterns ||= {
        "past"         => PointerDir::Past,
        /^future|in$/i => PointerDir::Future,
      }
    end

    def to_s
      "pointer-" + @type.to_s
    end
  end
end
