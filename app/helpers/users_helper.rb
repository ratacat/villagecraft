module UsersHelper
  def contextualized_user_link(user)
    name = (user === current_user) ? 'you' : user.name
    link_to name, user
  end
end
