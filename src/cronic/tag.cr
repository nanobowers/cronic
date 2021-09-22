module Cronic
  alias TagType = Int32 | Symbol | String | Tick

  # Tokens are tagged with subclassed instances of this class when
  # they match specific criteria.
  class Tag
    property :type
    property :width

    @width : Int32?
    @now : Time

    # stype - The Symbol type of this tag.
    def initialize(@type : TagType, @width : Int32? = nil, **options)
      @now = Time.local
    end

    # time - Set the start Time for this Tag.
    def start=(time)
      @now = time
    end

    # Public: Scan an Array of Token objects.
    #
    # tokens  - An Array of tokens to scan.
    # options - The Hash of options specified in Cronic::parse.
    #
    # Returns an Array of tokens.
    def self.scan(tokens, **options)
      raise NotImplementedError.new("Subclasses must override scan!")
    end

    # Internal: Match item and create respective Tag class.
    #           When item is a Symbol it will match only when it's identical to Token.
    #           When it's a String it will case-insesitively match partial token,
    #           but only if item's last char have different type than token text's next char.
    #           When item is a Regexp it will match by it.
    #
    # item    - Item to match. It can be String, Symbol or Regexp.
    # klass   - Tag class to create.
    # symbol  - Tag type as symbol or string to pass to Tag class.
    # token   - Token to match against.
    # options - Options as hash to pass to Tag class.
    #
    # Returns an instance of specified Tag klass or nil if item didn't match.
    private def self.match_item(item, klass, symbol, token, **options)
      match = false
      case item
      when String
        item_type = Tokenizer.char_type(item.to_s[-1])
        text_type = token.text[token.position + item.size]?
        text_type = Tokenizer.char_type(text_type) if text_type
        compatible = true
        compatible = item_type != text_type if text_type && (item_type == :letter || item_type == :digit)
        match = compatible && token.text[token.position, item.size].compare(item, case_insensitive: true).zero?
      when Symbol
        match = token.word == item.to_s
      when Regex
        match = token.word =~ item
      end
      return klass.new(symbol, nil, **options) if match
      nil
    end

    # Internal: Scan for specified items and create respective Tag class.
    #
    # token   - Token to match against.
    # klass   - Tag class to create.
    # items   - Item(s) to match. It can be Hash, String, Symbol or Regexp.
    #           Hash keys can be String, Symbol or Regexp, but values much be Symbol.
    # options - Options as hash to pass to Tag class.
    #
    # Returns an instance of specified Tag klass or nil if item(s) didn't match.
    # private
    def self.scan_for(token : Token, klass : Class, items, **options)
      # #p! token, klass, items
      if items.is_a?(Hash)
        items.each do |item, symbol|
          scanned = match_item(item, klass, symbol, token, **options)
          return scanned if scanned
        end
      else
        return match_item(items, klass, token.word, token, **options)
      end
      nil
    end
  end
end
