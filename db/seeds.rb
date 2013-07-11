# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

if Rails.env.development?
  # Some Locations
  berkeley = FactoryGirl.create(:location)
  oakland = FactoryGirl.create(:location, :city => "Oakland", :state_code => "CA")
  sf = FactoryGirl.create(:location, :city => "San Francisco", :state_code => "CA")
  sproul_loc = FactoryGirl.create(:location, :street => "2514 Bancroft Way")
  jareds_house_loc = FactoryGirl.create(:location, :street => "200 Vernon Street", :city => "Oakland", :state_code => "CA")
  bens_house_loc = FactoryGirl.create(:location, :street => "1006 Rose Ave", :city => "Piedmont", :state_code => "CA")
  dna_lounge_loc = FactoryGirl.create(:location, :street => "375 Eleventh St", :city => "San Francisco", :state_code => "CA", :zip => "94103")
  carnegie_hall_loc = FactoryGirl.create(:location, :street => "881 7th Ave", :city => "New York", :state_code => "NY", :zip => "10019")
  Location.find_each(&:save!) # forces 

  # Some Users
  images_path = Rails.root.join('spec', 'support', 'images')
  jared = FactoryGirl.create(:user, :first_name => "Jared", :last_name => "Smith", :email => "jared@example.com", :location => berkeley, :profile_image => File.open(images_path.join('jared.jpg')))
  ben = FactoryGirl.create(:user, :first_name => "Ben", :last_name => "Teitelbaum", :email => "ben@example.com", :location => oakland, :profile_image => File.open(images_path.join('ben.jpg')))
  jwz = FactoryGirl.create(:user, :first_name => "Jamie", :last_name => "Zawinski", :email => "jwz@example.com", :location => sf, :profile_image => File.open(images_path.join('jamie.jpg')))
  drones = []
  (1..20).each { drones << FactoryGirl.create(:random_user, :location => [berkeley, oakland, sf].sample) }

  # Some Venues
  sproul = FactoryGirl.create(:venue, :name => "Sproul Plaza", :owner => jared, :location => sproul_loc)
  jareds_house = FactoryGirl.create(:venue, :name => "Jared's House", :owner => jared, :location => jareds_house_loc)
  bens_house = FactoryGirl.create(:venue, :name => "Ben's House", :owner => ben, :location => bens_house_loc)
  dna_lounge = FactoryGirl.create(:venue, :name => "DNA Lounge", :owner => jwz, :location => dna_lounge_loc)
  carnegie_hall = FactoryGirl.create(:venue, :name => "Carnegie Hall", :owner => ben, :location => carnegie_hall_loc)
  
  # Some Events
  sourdough = FactoryGirl.create(:event, :title => "Sourdough Bread Making", :host => jared, :venue => jareds_house, :min_attendees => 3, :max_attendees => 10, :price => 5)
  parkour = FactoryGirl.create(:event, :title => "Parkour", :host => jared, :venue => sproul, :min_attendees => 5)
  throwies = FactoryGirl.create(:event, :title => "Build Your Own LED Throwies", :short_title => "LED throwies", :host => ben, :venue => bens_house, :min_attendees => 3, :price => 5)
  eff = FactoryGirl.create(:event, :title => "EFF Prism Smashing Fundraiser", :host => jwz, :venue => dna_lounge, :min_attendees => 0, :max_attendees => 1000, :price => 35)
  typewriter = FactoryGirl.create(:event, :title => "History of the Typewriter", :short_title => "typewriters", :host => ben, :venue => bens_house, :start_time => 3.weeks.ago, :end_time => (3.weeks.ago + 1.hour))
  
  # Some Attends
  (0..2).each { |i| drones[i].attends << sourdough }
  (0..2).each { |i| drones[i].attends << parkour }
  (0..5).each { |i| drones[i].attends << throwies }
  (0..19).each { |i| drones[i].attends << eff }
  (0..11).each do |i|
    at = Attendance.new
    at.user = drones[i]
    at.event = typewriter
    at.confirmed = [true, false, true].sample
    at.save!
  end
  jared.attends << typewriter
  ben.attends << typewriter
  
end
