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

# changes to Numeric!
describe Numeric do
  
  # this is a bit of a hacky spec
  it "should respond directly to a list of methods from Math" do
    math_methods = [:sin, :cos, :tan, :sinh, :cosh, :tanh, :asin, :acos, :atan, :asinh, :acosh, :atanh, :sqrt, :log10]
    math_methods.each do |method|
      subject.respond_to?(method).should == true
    end
  end
  
  describe "the log method" do
    it "should return the natural log if no argument is provided" do
      4.log.should == 4.log(Math::E)
    end
    
    it "should use the argument as the base, if provided" do
      4.log(2).should be_within(0.00001).of(2.0)
      4.log(10).should be_within(0.00001).of(0.60206)
      4.log(Math::E).should be_within(0.00001).of(1.38629)
    end
    
  end
end

describe FunctionalTerm do
  
  it "should require a function in the options provided" do
    expect do
      FunctionalTerm.new(:coefficient => 3, :argument => 4)
    end.to raise_error(NoFunctionProvidedException)
  end
  
  it "should set the coefficient to 1 if none is provided" do
    term = FunctionalTerm.new(:function => :**, :argument => 4)
    term.options[:coefficient].should == 1
  end
  
  it "should set the argument to 1 if none is provided, and function is not :log" do
    term = FunctionalTerm.new(:function => :sin)
    term.options[:argument].should == 1
  end
  
  it "should set the argument to Math::E if function is :log, and argument is not provided" do
    term = FunctionalTerm.new(:function => :log)
    term.options[:argument].should == Math::E
  end
  
  it "should require an argument to be passed for certain functions" do
    functions_requiring_arguments = [:+, :-, :*, :/, :**]
    functions_requiring_arguments.each do |f|
      expect do
        FunctionalTerm.new(:function => f)
      end.to raise_error(ArgumentError, "the #{f} function needs an :argument to be provided")
    end
  end
  
end