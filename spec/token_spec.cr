require "./spec_helper"

module Cronic
  # fake tag classes for testing..
  class StringTag < Cronic::Tag; end

  class IntTag < Cronic::Tag; end
end

describe Cronic::Token do
  it("token") do
    token = Cronic::Token.new("foo")
    token.tags.size.should eq 0
    token.tagged?.should_not be_truthy
    token.tag(Cronic::StringTag.new("mytag"))
    token.tags.size.should eq 1
    token.tagged?.should eq true

    token.get_tag(Cronic::StringTag).class.should eq Cronic::StringTag
    token.tag(Cronic::IntTag.new(5))
    token.tags.size.should eq 2

    token.untag(Cronic::StringTag)
    token.tags.size.should eq 1
    token.word.should eq "foo"
  end
  it("token inspect doesnt mutate the word") do
    token = Cronic::Token.new("foo")
    token.inspect
    token.word.should eq "foo"
  end
end
