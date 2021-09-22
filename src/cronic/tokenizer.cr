module Cronic
  module Tokenizer
    def self.char_type(char)
      return :period if char == '.'
      return :letter if char.letter?
      return :digit if char.number?
      return :space if char.whitespace?
      return :punct if ' ' < char < '0'
      return :other
    end

    # Process text to tokens
    def self.tokenize(text) : Array(Token)
      tokens = [] of Token
      index = 0
      previos_index = 0
      text.each_char do |char|
        if char.whitespace?
          tokens << Token.new(text[previos_index...index], text, previos_index)
          previos_index = index + 1
        end
        index += 1
      end
      tokens << Token.new(text[previos_index...index], text, previos_index)
      tokens
    end
  end
end
