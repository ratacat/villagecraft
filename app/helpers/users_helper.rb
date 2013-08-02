module UsersHelper
  def contextualized_user_link(user)
    return 'a former user' if user.blank?
    name = (user === current_user) ? 'you' : user.name
    link_to name, user
  end
  
  def formatted_velocity(user)
    number_to_percentage(user.velocity * 100, precision: 0)
  end
end
