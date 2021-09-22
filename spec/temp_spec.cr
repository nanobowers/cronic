require "./spec_helper"

#Cronic.debug = true

describe Cronic::Token do
  #  it "tokenizes something" do
  #    par = Cronic::Parser.new
  #    p par.tokenize("15th of january")
  #  end

  it "parses something" do
    zz = Cronic.parse("15th of january")
    p zz
    # p! Cronic.parse("15th of jan")
  end

  it "parses something2" do
    zz = Cronic.parse("22-feb")
    p zz
    # p! Cronic.parse("15th of jan")
  end

  it "parses something2" do
    time = Cronic.parse("tomorrow at 0900", now: Time.local(2006, 8, 16, 14, 0, 0))
    time.should eq Time.local(2006, 8, 17, 9)
  end

  it "numerizes" do
    p! NumberParser.parse("fourth")
    p! NumberParser.parse("a fourth")
    p! NumberParser.parse("one fourth")
    p! NumberParser.parse("two fourths")
    p! NumberParser.parse("may fourth")

    p! NumberParser.parse("fourth", bias: :ordinal)
    p! NumberParser.parse("a fourth", bias: :ordinal)
    p! NumberParser.parse("one fourth", bias: :ordinal)
    p! NumberParser.parse("two fourths", bias: :ordinal)
    p! NumberParser.parse("may fourth", bias: :ordinal)

    p! NumberParser.parse("fourth", bias: :fractional)
    p! NumberParser.parse("a fourth", bias: :fractional)
    p! NumberParser.parse("one fourth", bias: :fractional)
    p! NumberParser.parse("two fourths", bias: :fractional)
    p! NumberParser.parse("may fourth", bias: :fractional)
  end

  it "numerizes" do
    p! NumberParser.parse("tenth")
    p! NumberParser.parse("a tenth")
    p! NumberParser.parse("one tenth")
    p! NumberParser.parse("two tenths")
    p! NumberParser.parse("may tenth")

    p! NumberParser.parse("tenth", bias: :ordinal)
    p! NumberParser.parse("a tenth", bias: :ordinal)
    p! NumberParser.parse("one tenth", bias: :ordinal)
    p! NumberParser.parse("two tenths", bias: :ordinal)
    p! NumberParser.parse("may tenth", bias: :ordinal)

    p! NumberParser.parse("tenth", bias: :fractional)
    p! NumberParser.parse("a tenth", bias: :fractional)
    p! NumberParser.parse("one tenth", bias: :fractional)
    p! NumberParser.parse("two tenths", bias: :fractional)
    p! NumberParser.parse("may tenth", bias: :fractional)
  end
end
