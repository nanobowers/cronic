require "./spec_helper"

Cronic.debug = true

describe Cronic::Token do
#  it "tokenizes something" do
#    par = Cronic::Parser.new
#    p par.tokenize("15th of january")
  #  end
  
  it "parses something" do
    zz = Cronic.parse("15th of january")
    p zz
    #p! Cronic.parse("15th of jan")
  end

  it "parses something2" do
    zz = Cronic.parse("22-feb")
    p zz
    #p! Cronic.parse("15th of jan")
  end

  it "parses something2" do
    time = Cronic.parse("tomorrow at 0900", now: Time.local(2006, 8, 16, 14, 0, 0))
    time.should eq Time.local(2006, 8, 17, 9)
  end
  
end
