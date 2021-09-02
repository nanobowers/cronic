require "./spec_helper"

describe Cronic::Token do

  it("token") do
    token = Cronic::Token.new("foo")
    token.tags.size.should eq 0
    token.tagged?.should_not be_truthy
    token.tag( Cronic::Tag.new("mytag"))
    token.tags.size.should eq 1
    token.tagged?.should eq true

    #TODO# token.get_tag(String).class.should eq String

    token.tag( Cronic::Tag.new(5) )
    token.tags.size.should eq 2

    #TODO broken untag   
    #    token.untag(String)
    #    token.tags.size.should eq 1
    #    token.word.should eq "foo"
  end
  it("token inspect doesnt mutate the word") do
    token = Cronic::Token.new("foo")
    token.inspect
    token.word.should eq "foo"
  end
end
