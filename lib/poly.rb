class PolynomialExpression
  attr_accessor :terms
  
  def initialize(*terms)
    @terms = terms.flatten
  end
  
  def call(x)
    @terms.inject(0){|sum, t| sum + t.call(x) }
  end
  
  def derivative
    PolynomialExpression.new(@terms.map{|t| t.derivative })
  end
  
  def newton(guess, precision = 1.0e-20)
    if self.call(guess).abs <= precision
      guess
    else
      newton(guess - (self.call(guess).to_f / self.derivative.call(guess).to_f), precision)
    end
  end
  
  def to_s
    @terms.sort_by(&:exponent).reverse.map(&:to_s).join(" + ")
  end
end

class PolynomialTerm
  attr_accessor :coefficient, :exponent
  
  def initialize(coefficient = 0, exponent = 0)
    @coefficient = coefficient
    @exponent = exponent
  end
  
  def call(x)
    @coefficient * x ** @exponent
  end
  
  def derivative
    PolynomialTerm.new(@coefficient * @exponent, @exponent - 1)
  end
  
  def to_s
    "#{@coefficient}#{@exponent != 0 ? (@exponent == 1 ? 'x' : 'x^' + @exponent.to_s) : ''}"
  end
end