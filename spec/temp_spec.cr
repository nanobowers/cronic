require "./spec_helper"

Cronic.debug = true

describe Cronic::Token do
#  it "tokenizes something" do
#    par = Cronic::Parser.new
#    p par.tokenize("15th of january")
  #  end
  
  it "parses something" do
    #p! Cronic.parse("15th of january")
    p! Cronic.parse("15th of jan")
  end
end
