module VenuesHelper
  ADD_NEW_VENUE_PROMPT = "Add new venue..."
  
  def users_venue_options(user)
    tbd = Venue.new(:name => "TBD")
    add_new = Venue.new(:name => ADD_NEW_VENUE_PROMPT)
    [tbd] + user.owned_venues + [add_new]
  end
  
  def blur_venue_location?(venue)
    return false if venue.public?
    return true unless user_signed_in?
    return false if current_user === venue.owner
    # current_user has attended (or will attend) an event at this venue
    current_user.venues.where(:id => venue.id).blank?
  end
  
end
