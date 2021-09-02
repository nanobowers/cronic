module Cronic
  module Tokenizer
    def self.char_type(char)
      case char
      when '.'
        :period
      when /[[:alpha:]]/
        :letter
      when /[[:digit:]]/
        :digit
      when /[[:space:]]/
        :space
      when /[[:punct:]]/
        :punct
      else
        :other
      end
    end

    # Process text to tokens
    def self.tokenize(text) : Array(Token)
      tokens = [] of Token
      index = 0
      previos_index = 0
      text.each_char do |char|
        #chtype = char_type(char.to_s)
        #p! char, chtype
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
