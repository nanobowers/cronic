require "./definition"

module Cronic
  
  # A collection of SpanDefinitions
  class SpanDictionary 

    def initialize(**kwargs)
#      @defined_items = {"time" => TimeDefinitions,
#                        "date" => DateDefinitions,
#                        "anchor" => AnchorDefinitions,
#                        "arrow" => ArrowDefinitions,
#                        "narrow" => NarrowDefinitions,
#                        "endian" => EndianDefinitions }
    end

    # returns a hash of each word's Definitions
    def definitions : Hash(String, Array(Handler))
      {"time" => TimeDefinitions.new.definitions,
       "date" => DateDefinitions.new.definitions,
       "anchor" => AnchorDefinitions.new.definitions,
       "arrow" => ArrowDefinitions.new.definitions,
       "narrow" => NarrowDefinitions.new.definitions,
       "endian" => EndianDefinitions.new.definitions }
    end

    # returns the definitions of a specific subclass of SpanDefinitions
    # SpanDefinition#definitions returns an Hash of Handler instances
    # arguments should come in as symbols
    def [](handler_type=:symbol)
      definitions[handler_type]
    end
  end
end
