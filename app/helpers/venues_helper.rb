module VenuesHelper
  ADD_NEW_VENUE_PROMPT = "Add new venue..."
  
  def users_venue_options(user)
    tbd = Venue.new(:name => "TBD")
    add_new = Venue.new(:name => ADD_NEW_VENUE_PROMPT)
    [tbd] + user.venues + [add_new]
  end
end
