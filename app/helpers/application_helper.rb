module ApplicationHelper
  # credit: https://stackoverflow.com/a/5391745
  def link_to_image(image_path, target_link,options={})
    link_to(image_tag(image_path, :border => "0"), target_link, options)
  end

end
