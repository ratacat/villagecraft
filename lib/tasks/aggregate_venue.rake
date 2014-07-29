# -*- encoding: utf-8 -*-

task :aggregate_venue => :environment do
  locations = Location.order(:id)
  puts "Locations"
  locations.each do |location|
    location.save
    print "."

  end
  venue_ids = Venue.order(:id).collect{|x| x.id}
  puts "Venues"
  venue_ids.each do |venue_id|
    venue = Venue.find_by_id(venue_id)
    print "."
    $stdout.flush
    if venue.present?

      location = venue.location
      locations = Location.where(latitude: location.latitude, longitude: location.longitude, address: location.address).where("id <> ?", location.id)
      location_ids = locations.map{|x| x.id}
      Event.where(location_id: location_ids).update_all(location_id: location.id)
      Sighting.where(location_id: location_ids).update_all(location_id: location.id)
      User.where(location_id: location_ids).update_all(location_id: location.id)

      tmp_venues = Venue.where(location_id: location_ids)
      tmp_venues.update_all(location_id: location.id)

      tmp_venues_ids = Venue.where(location_id: location.id).map{|x| x.id}

      Event.where(venue_id: tmp_venues_ids).update_all(venue_id: venue_id)
      Meeting.where(venue_id: tmp_venues_ids).update_all(venue_id: venue_id)
      Workshop.where(venue_id: tmp_venues_ids).update_all(venue_id: venue_id)
      locations.destroy_all
      Venue.where(location_id: location.id).where("id <> ?", venue_id).destroy_all
    end
  end

end