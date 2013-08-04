module UsersHelper
  def contextualized_user_link(user)
    return 'a former user' if user.blank?
    name = (user === current_user) ? 'you' : user.name
    link_to name, user
  end
  
  def formatted_velocity(user)
    number_to_percentage(user.velocity * 100, precision: 0)
  end
  
  def contextualized_user_name(user, options={})
    viewing_user = (options[:viewer] || current_user)
    if user.blank?
      options[:capitalize] ? 'A former user' : 'a former user'
    elsif user === viewing_user
      options[:capitalize] ? 'You' : 'you'
    else
      user.name
    end
  end
  
end
