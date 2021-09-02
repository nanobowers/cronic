module Cronic
  class Handler

    getter :pattern

    getter :handler_method

    alias Pattern = Array(String) | Array(String | Array(String))
    
    # pattern        - An Array of patterns to match tokens against.
    # handler_method - A Symbol representing the method to be invoked
    #   when a pattern matches.
    def initialize(@pattern : Pattern, @handler_method : String?)
      #@pattern = pattern
      #@handler_method = handler_method
    end

    # tokens - An Array of tokens to process.
    # definitions - A Hash of definitions to check against.
    #
    # Returns true if a match is found.
    def match(tokens, definitions)
      token_index = 0
      @pattern.each do |elements|
        was_optional = false
        elements = [elements] unless elements.is_a?(Array)

        elements.each_index do |i|
          name = elements[i].to_s
          optional = (name[-1, 1] == '?')
          name = name[0..-2] if optional

          case elements[i]
#          when Symbol

          when String # Symbol
            if tags_match?(name, tokens, token_index)
              token_index += 1
              break
            else
              if optional
                was_optional = true
                next
              elsif i + 1 < elements.size
                next
              else
                return false unless was_optional
              end
            end

            return true if optional && token_index == tokens.size
        # when String
            if definitions.has_key?(name)
              sub_handlers = definitions[name]
            else
              raise RuntimeError.new("Invalid subset `#{name}` specified.  Def-names: #{definitions.keys}")
            end

            sub_handlers.each do |sub_handler|
              return true if sub_handler.match(tokens[token_index..tokens.size], definitions)
            end
          else
            raise RuntimeError.new("Invalid match type: #{elements[i].class}")
          end
        end

      end

      return false if token_index != tokens.size
      return true
    end

    def invoke(stype, tokens, parser, options)
      if Cronic.debug
        puts "-#{stype}"
        puts "Handler: #{@handler_method}"
      end
      # No send, so have to define all of the handler method mappings here :(
      p! @handler_method
      case @handler_method
      when :abc then Span.new(::Time.local, ::Time.local)
      else
        Span.new(::Time.local, ::Time.local)
      end
      #parser.send(@handler_method, tokens, options)
    end

    # other - The other Handler object to compare.
    #
    # Returns true if these Handlers match.
    def ==(other)
      @pattern == other.pattern
    end

    private def tags_match?(name, tokens, token_index)
      constname = name.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
      #p! constname
      
#      klass = Cronic.const_get(constname)
      
      if tokens[token_index]?
           seltokens = tokens[token_index].tags.select do |o|
             p [name, constname, o.class]
             o.class.to_s == constname # kind_of?(klass)
           end
           return !seltokens.empty?
      end
      false
    end

  end
end
