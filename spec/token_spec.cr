require "./spec_helper"

describe Cronic::Token do

  now : Time
  Spec.before_each { now = Time.local(2006, 8, 16, 14, 0, 0, 0) }

  it("token") do
    token = Cronic::Token.new("foo")
    token.tags.size.should eq 0
    (not token.tagged?).should be_truthy
    token.tag("mytag")
    token.tags.size.should eq 1
    token.tagged?.should eq true
    token.get_tag(String).class.should eq String
    token.tag(5)
    token.tags.size.should eq 2
    token.untag(String)
    token.tags.size.should eq 1
    token.word.should eq "foo"
  end
  it("token inspect doesnt mutate the word") do
    token = Cronic::Token.new("foo")
    token.inspect
    token.word.should eq "foo"
  end
end
