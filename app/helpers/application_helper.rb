module ApplicationHelper
  def format_money(num)
    if num.class == Float || num.class == Integer
      if num >= 0
        return sprintf("%.02f", num).prepend("$")
      else
        return sprintf("%.02f", num * -1).prepend("-$")
      end
    else
      return num
    end
  end
end
