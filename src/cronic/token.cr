module Cronic
  class Token

    property :word
    property :tags

    getter :text
    getter :position

    #@text : String?
    
    def initialize(@word : String, @text : String = "", position = 0)
      @word = word
      @tags = [] of Tag
      @text = text
      @position = position
    end

    def ==(token)
      token.word == @word.downcase
    end

    # Tag this token with the specified tag.
    # Returns nothing.
    def tag(new_tag : Tag?)
      @tags << new_tag if new_tag
    end

    # Returns true if this token has any tags.
    def tagged? : Bool
      @tags.size > 0
    end

    # Remove all tags of the given class.
    # tag_class - The tag Class to remove.
    # Returns nothing.

    def untag(tag_class)
      @tags.reject! { |m| m.class == tag_class }
    end


    # tag_class - The tag Class to search for.
    # Returns The first Tag that matches the given class.
    def get_tag(tg_class : Class)
      @tags.find { |m|
        m.class == tg_class
      }
    end

    # Print this Token in a pretty way
    def to_s : String
      @word + "(" + @tags.join(", ") + ") "
    end

    def inspect
      to_s
    end
  end

end
