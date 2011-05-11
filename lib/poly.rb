
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

class FunctionalTerm
  attr_accessor :options, :derivatives
  
  def initialize(options)
    @options = options
    @options[:coefficient] ||= 1
    
    
    if @options[:function] == nil
      raise NoFunctionProvidedException.new("you can't have a functional term that doesn't have a function")
    end
    
    if @options[:function] == :log
      @options[:argument] ||= Math::E
    else
      @options[:argument] ||= 1
    end
    
    if [:+, :-, :*, :/, :**].include?(@options[:function]) && @options[:argument] == nil
      raise ArgumentError.new("the #{@options[:function]} function needs an :argument to be provided")
    end
    
    @derivatives = {
      :**     => {:coefficient => @options[:coefficient] * @options[:argument], :function => :**, :argument => @options[:argument] - 1},
      :log    => {:function => lambda{|n| 1.0/n*(@options[:argument].nil? ? 1 : @options[:argument].log)}},
      :sin    => {:function => :cos},
      :cos    => {:coefficient => -1, :function => :sin},
      :tan    => {:function => lambda{|n| 1.0/n.cos**2 }},
      :arcsin => {:function => lambda{|n| 1.0/((1 - n**2).sqrt)}},
      :arccos => {:coefficient => -1, :function => lambda{|n| 1.0/((1 - n**2).sqrt)}},
      :arctan => {:function => lambda{|n| 1.0/(1 + n**2)}}
    }
  end
  
  def call(x)
    
    if @options[:function].is_a?(Proc)
      # none of the lambda's in derivatives accept a second argument, so...
      @options[:coefficient] * @options[:function].call(x)
    else
      # receiver will ignore the second option if it doesn't need an argument.
      @options[:coefficient] * x.send(@options[:function], @options[:argument])
    end 
  end
  
  def derivative
    # hmmm.
    # well, this is a little complicated. We could use a big case statement, but...
    FunctionalTerm.new(@derivatives[@options[:function]])
    # this is pretty fragile. Clearly, this will ONLY work if the :function is a symbol, not a Proc.
  end
  
end

class FunctionalExpression
  attr_accessor :terms
  
  def initialize(*terms)
    @terms = terms.flatten
  end
  
  def call(x)
    @terms.inject(0){|sum, t| sum + t.call(x) }
  end
  
  def derivative
    FunctionalExpression.new(@terms.map{|t| t.derivative })
  end
  
  def newton(guess, precision = 1.0e-20)
    if self.call(guess).abs <= precision
      guess
    else
      newton(guess - (self.call(guess).to_f / self.derivative.call(guess).to_f), precision)
    end
  end
  
end


class Numeric
  
  [:sin, :cos, :tan, :sinh, :cosh, :tanh, :asin, :acos, :atan, :asinh, :acosh, :atanh, :sqrt, :log10].each do |method_name|
    define_method(method_name) { |*arg|
      if !arg.empty?
        Math.send(method_name, self, arg)
      else
        Math.send(method_name, self)
      end
    }
  end
  
  def log(base = nil)
    if base.nil?
      Math.log(self)
    else
      Math.log(self) / Math.log(base)
    end
  end
  
end

class NoFunctionProvidedException < Exception

end