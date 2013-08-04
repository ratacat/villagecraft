module UsersHelper
  def linked_user_thumb(user)
    link_to image_tag(user.profile_img_src(:thumb), :class => 'img-rounded'), user
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
