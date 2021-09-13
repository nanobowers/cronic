require "./spec_helper"

describe "tokenizing" do
  it "tokenizes something with a time in it" do
    par = Cronic::Parser.new

    toks = par.tokenize("15th of january at 8am")

    toks.each do |tok|
      p tok
    end
  end

end
