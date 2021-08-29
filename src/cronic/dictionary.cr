require "./definition"

module Cronic
  
  # A collection of Definitions
  class Dictionary
    getter :defined_items, :options

    def initialize(**options)
      @options = options
      @defined_items = [] of String
    end

    # returns a hash of each word's Definitions
    def definitions
      defined_items.each_with_object() do |word, defs|
        word_type = "#{word.capitalize.to_s + "Definitions"}"
        defs[word] = Cronic.const_get(word_type).new(options).definitions
      end
    end
  end

  # A collection of SpanDefinitions
  class SpanDictionary < Dictionary

    def initialize(**kwargs)
      super
      @defined_items = [:time,:date,:anchor,:arrow,:narrow,:endian]
    end

    # returns the definitions of a specific subclass of SpanDefinitions
    # SpanDefinition#definitions returns an Hash of Handler instances
    # arguments should come in as symbols
    def [](handler_type=:symbol)
      definitions[handler_type]
    end
  end
end
