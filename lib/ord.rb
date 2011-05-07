class Fixnum
  require 'rubygems'
  require 'linguistics'
  
  def to_words
    Linguistics::EN.numwords(self, :and => ' ')
  end
  
  def to_ordinal
    Linguistics::EN.ordinal(self.to_words)
  end
  
  def to_ordinalscore
    self.to_ordinal.gsub('-', "_").gsub(" ", "_")
  end
end

class String
  MULT = {"trillion" => 1000000000000, "trillionth" => 1000000000000, "billion" => 1000000000, "billionth" => 1000000000,
    "million" => 1000000, "millionth" => 1000000,
    "thousand" => 1000, "thousandth" => 1000, "hundred" => 100, "hundredth" => 100
  }
  
  TENS = {"ten" => 10, "tenth" => 10, "eleven" => 11, "eleventh" => 11, "twelve" => 12, "twelfth" => 12, "thirteen" => 13, "thirteenth" => 13,
    "fourteen" => 14, "fourteenth" => 14, "fifteen" => 15, "fifteenth" => 15, "sixteen" => 16, "sixteenth" => 16,
    "seventeen" => 17, "seventeenth" => 17, "eighteen" => 18, "eighteenth" => 18, "nineteen" => 19, "nineteenth" => 19,
    "twenty" => 20, "twentieth" => 20, "thirty" => 30, "thirtieth" => 30, "forty" => 40, "fortieth" => 40, "fifty" => 50, "fiftieth" => 50,
    "sixty" => 60, "sixtieth" => 60, "seventy" => 70, "seventieth" => 70, "eighty" => 80, "eightieth" => 80, "ninety" => 90, "ninetieth" => 90
  }
  
  ONES = {"one" => 1, "first" => 1, "two" => 2, "second" => 2, "three" => 3, "third" => 3, "four" => 4, "fourth" => 4, 
    "five" => 5, "fifth" => 5, "six" => 6, "sixth" => 6, "seven" => 7, "seventh" => 7, "eight" => 8, "eighth" => 8,
    "nine" => 9, "ninth" => 9
  }
  
  def to_fixnum
    arr = self.split("_")
    m_arr = arr.include?("million") ? arr.slice!(0..arr.index("million")) : nil
    t_arr = arr.include?("thousand") ? arr.slice!(0..arr.index("thousand")) : nil
    h_arr = arr
    
    nums = [m_arr, t_arr, h_arr].compact
    nums.each do |a|
      a.map!{|n| if ONES.include?(n); ONES[n]; elsif TENS.include?(n); TENS[n]; elsif MULT.include?(n); MULT[n]; end}
    end
    if nums.flatten.any?{|n| !n.is_a?(Fixnum)}
      raise NotReallyANumber
      # return nums
    end
    sum = 0
    nums.each do |e|
      m = MULT.values.include?(e.last) ? e.pop : 1
      toeval = "(0"
      e.each{|n| if n > 99; toeval << ") * #{n} + (0"; else; toeval << " + #{n}"; end }
      toeval << ")"
      sum += eval(toeval) * m
    end
    
    sum
    
  end
end

class Array
  def method_missing(method, *args)
    n = method.to_s.to_fixnum
    if n.is_a?(Fixnum)
      self[method.to_s.to_fixnum - 1]
    else
      super
    end
  end
  
  def any?(&block)
    self.inject(false){ |truthiness, n| truthiness || block.call(n) }
  end
  
  def all?(&block)
    self.inject(true){ |truthiness, n| truthiness && block.call(n) }
  end
end

class NotReallyANumber < Exception
  def message
    "It doesn't look like this string can be changed into a number."
  end
end