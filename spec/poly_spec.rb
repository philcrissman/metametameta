require 'rubygems'
require 'rspec'
require 'lib/poly.rb'


describe PolynomialTerm do
  before(:all) do
    @term = PolynomialTerm.new(2, 3) # 2 * x ** 3
  end
  
  it "should evaluate itself" do
    @term.call(2).should == 16
  end
  
  it "should return it's own derivative" do
    @deriv = @term.derivative # 6 * x ** 2
    @deriv.is_a?(PolynomialTerm).should be true
    @deriv.call(2).should == 24
  end
  
  it "should return a mathy string representation of itself" do
    @term.to_s.should == "2x^3"
  end
  
end

describe PolynomialExpression do
  before(:all) do
    @expression = PolynomialExpression.new(
      PolynomialTerm.new(2, 3),
      PolynomialTerm.new(4, 2),
      PolynomialTerm.new(-3, 1),
      PolynomialTerm.new(-7, 0)
    )
  end
  
  
  it "should evaluate itself by summing the evaluations of its terms" do
    @expression.call(2).should == 16 + 16 - 6 - 7
  end
  
  it "should return it's derivative as an expression made up of the derivatives of its terms" do
    deriv = @expression.derivative
    deriv.is_a?(PolynomialExpression).should == true
    deriv.terms.count.should == 4
    deriv.call(2).should == 24 + 16 + -3 + 0
  end
  
  it "should find zeroes of the expression using newtons method" do
    @expression.newton(1.3).should be_within(0.00001).of(1.28538) # expected root from WolframAlpha
  end
  
  it "should return a string made up of the strings of its terms, separated by '+'" do
    @expression.to_s.should == "2x^3 + 4x^2 + -3x + -7"
  end
end

