module VenuesHelper
  ADD_NEW_VENUE_PROMPT = "Add a new location..."
  
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

  def inline_venue(venue, options = {})
    defaults = {
      :linked => false,
      :only_path => true
    }
    options.reverse_merge!(defaults)
    
    if venue.blank?
      'TBD'
    else
      link_to_if(options[:linked], venue.name, venue_url(venue, :only_path => options[:only_path]))
    end
  end
  
end
