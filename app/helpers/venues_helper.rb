module VenuesHelper
  ADD_NEW_VENUE_PROMPT = "Add new venue..."
  
  def users_venue_options(user)
    tbd = Venue.new(:name => "TBD")
    [tbd] + user.owned_venues
  end
  
  def blur_venue_location?(venue)
    return false if venue.public?
    return true unless user_signed_in?
    return false if current_user === venue.owner
    # current_user has attended (or will attend) an event at this venue
    current_user.venues.where(:id => venue.id).blank?
  end

  def inline_venue(venue, options = {})
    defaults = {
      :linked => false
    }
    options.reverse_merge!(defaults)
    
    if venue.blank?
      'TBD'
    else
      link_to_if(options[:linked], venue.name, venue)
    end
  end
  
end
