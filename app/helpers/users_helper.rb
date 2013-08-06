module UsersHelper
  def linked_user_thumb(user, options={})
    defaults = {:size => :thumb}
    options.reverse_merge!(defaults)
    if user
      link_to image_tag(user.profile_img_src(options[:size]), :class => 'img-rounded'), user
    else
      image_tag(User.homunculus_src(options[:size]), :class => 'img-rounded')
    end
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
    name.capitalize! if options[:capitalize]
    name
  end
  
end
