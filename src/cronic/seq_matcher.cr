module Cronic
  class SeqMatcher
    #
    # Matching routines, kind of like a poor-man's regex
    # Supports a single Sequence with a single nesting of
    # Or's and Maybe's
    #

    def self.match_one(pat, tok : Token) : Bool
      if pat.is_a?(Or)
        # puts ">> checking #{tok.inspect} against #{pat}"
        return pat.items.any? { |x| self.match_one(x, tok) }
        # TODO
        #      elsif pat.is_a?(Sequence)
        #        raise Exception.new("illegal to get seq in match_one")
        #        #return self.match_one(pat.first, tok)
      else
        # puts ">> checking #{tok.inspect} against #{pat}"
        return tok.tags.any? { |t| pat >= t.class }
      end
    end

    def self.match_maybe(pattern, tokens : Array(Token)) : Bool
      if self.match_one(pattern.first, tokens.first) && self.match(pattern[1..], tokens[1..])
        return true
      else
        return self.match(pattern[1..], tokens)
      end
    end

    def self.match(pattern, tokens : Array(Token)) : Bool
      # puts ">> matching #{pattern.inspect}<<"
      if pattern.empty?
        return true if tokens.empty?
        return false # if we still have leftover tokens

        # TODO
        #      elsif pattern.first.is_a?(Sequence)
        #        firstpat = pattern.first.as(Sequence)
        #        seqfirst = firstpat.first
        #        seqrest = firstpat.rest
        #        return self.match_one(seqfirst, tokens[0]) && self.match(seqrest, tokens[1..])

      elsif pattern.first.is_a?(Or)
        firstpat = pattern.first.as(Or)
        oritems = firstpat.items
        anyormatch = oritems.any? { |oritem|
          tokens.empty? ? false : self.match_one(oritem, tokens[0])
        }
        orclause = anyormatch && self.match(pattern[1..], tokens[1..])
        if orclause
          # if any of the or-cases plus the rest matched then good
          return true
        elsif firstpat.maybe?
          # if we had a maybe, then try the case where we skip the first
          # item in the pattern
          return self.match(pattern[1..], tokens)
        else
          false
        end
      elsif tokens.empty?
        return false # fail b/c no tokens left
      else
        return self.match_one(pattern[0], tokens[0]) && self.match(pattern[1..], tokens[1..])
      end
    end
  end
end
