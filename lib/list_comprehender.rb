class ListComprehender
  
  # meh. Doesn't _really_ work like I'd like it to. 
  # But you can do:
  #  lc = ListComprehender.new
  #  lc["x**2 for x in (1..20) unless x%2 == 0"]
  # and that sort of thing. Complex initial expressions aren't working.
  
  def [](expression = "")
    unless expression.empty?
      # split into 4 parts: variable, variable_expression, enumerable, modifying_expression
      matches = expression.match(/for (\S*) in (\d\.{2,3}\d|\[.*\]|\S*)/)
      
      enumerable = matches[2]
      enumerable = eval("("+enumerable+")").is_a?(Range) ? "("+enumerable+")" : enumerable
      
      variable = matches[1]
      
      variable_expression = matches.pre_match.rstrip
      
      modifying_expression = matches.post_match.lstrip
      
      eval(enumerable + ".map{|" + variable + "| " + variable_expression + " " + modifying_expression + "}.compact")
    end
  end
  
end