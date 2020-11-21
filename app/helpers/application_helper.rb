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

  # credit: https://stackoverflow.com/a/5391745
  def link_to_image(image_path, target_link,options={})
    link_to(image_tag(image_path, :border => "0"), target_link, options)
  end

end
