module UsersHelper
  def user_thumb(user, options={})
    defaults = {
      :size => :thumb,
      :linked => false
    }
    options.reverse_merge!(defaults)
    html = image_tag(user.try(:profile_img_src, options[:size]) || User.homunculus_src(options[:size]), :class => 'img-rounded')
    (options[:linked] and user) ? link_to(html, user) : html
  end
  
  def linked_user_thumb(user, options={})
    options[:linked] = true
    user_thumb(user, options)
  end
  
  def contextualized_user_link(user, options={})
    link_to contextualized_user_name(user, options), user
  end
  
  def formatted_velocity(user)
    number_to_percentage(user.velocity * 100, precision: 0)
  end
  
  def contextualized_user_name(user, options={})
    viewing_user = (options[:viewer] || current_user)
    name = 
    if user.blank?
      'a former user'
    elsif user === viewing_user
      options[:capitalize] ? 'You' : 'you'
    else
      user.name
    end
    name
  end
  
  def rich_user_thumbnail(user, options={})
    defaults = {
      :thumbnail_classes => 'thumbnail right-caption clearfix',
      :thumb_options => {:size => :thumb, :linked => true},
      :user_link_options => {}
    }
    options.reverse_merge!(defaults)
    content_tag(:div, :class => options[:thumbnail_classes]) do
      user_thumb(user, options[:thumb_options]) +
      contextualized_user_link(user, options[:user_link_options])
    end
  end
end
