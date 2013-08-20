# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

#
# Seed neighborhoods table for all environments
#
# Add more states here after installing the neighborhood boundary files from Zillow (http://www.zillow.com/howto/api/neighborhood-boundaries.htm)
states = ['CA']
states.each do |state|
  Rake::Task['db:load_zillow_hoods'].invoke(state)
end

#
# Useful seed data to play with in development
#
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
  edible_schoolyard_loc = FactoryGirl.create(:location, :street => "1781 Rose St", :city => "Berkeley", :state_code => "CA")
  house66_loc = FactoryGirl.create(:location, :street => "1406 66th street", :city => "Berkeley", :state_code => "CA")
  
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
  edible_schoolyard = FactoryGirl.create(:venue, :name => "The Edible Schoolyard", :owner => ben, :location => edible_schoolyard_loc)
  house66 = FactoryGirl.create(:venue, :name => "House on 66th", :owner => jared, :location => house66_loc)
  
  # Some Events
  sourdough = FactoryGirl.create(:event, :title => "Sourdough Bread Class", :host => jared, :venue => jareds_house, :min_attendees => 3, :max_attendees => 6, :description => "Sourdough has been used since the invention of bread to cultivate and encourage wild yeasts that occur in everything to help make delicious, fluffy, sour bread. The distinctive sour taste comes from the cultivated family of lactobacillus bacteria and yeasts. These tiny lifeforms have long since allied themselves as human digestive flora.  Bread that is cultured with lactobacillus is easier to digest then commercial bakers yeast.<br><br>Please bring a small bread pan, clothing that can get flour on it. And anything you want to spread on your bread.  You will learn the entire process from beginning to end, and everyone gets to take a fresh loaf of bread home. (also some of your very own starter)")
  parkour = FactoryGirl.create(:event, :title => "Parkour & Movement Training", :host => jared, :venue => sproul, :min_attendees => 2, :max_attendees => 7, :start_time => (1.days.from_now + 5.hours), :end_time => (1.days.from_now + 7.hours), :description => "Parkour is the art and science of efficient movement over and through obstacles. This class is an adult basics, suitable for all ages above 18. We will be using simple progressive techniques to learn a huge variety of playful and practical abilities. All body types are encouraged!  Parkour is an individual practice, which means you work to become comfortable with and expand your own abilities in a safe and supportive environment.")
  throwies = FactoryGirl.create(:event, :title => "Small Business Social Media Training", :short_title => "Search Optimization", :host => ben, :venue => bens_house, :min_attendees => 3, :price => 25, :start_time => (5.hours.from_now), :end_time => (7.hours.from_now), :description => "Remember the old maxim 'Location! Location! Location!'?  As we usher in the information age, this saying has never been more relevant.  Except now it's referring to less your physical location, and more to the location of your business listings!  People explore their cities with their cellphones!  And the better off your positions, the more feet you get in your door.  This class is targetted to Small Business owners that are looking to take their future into their own hands. You don't need to be an uber nerd to learn more about how to build your business a better digital location.")
  spanish = FactoryGirl.create(:event, :title => "Practice your Spanish by playing board games!", :short_title => "Practice Spanish", :host => ben, :venue => bens_house, :start_time => (3.days.from_now), :end_time => (3.days.from_now + 1.hour), :min_attendees => 2, :max_attendees => 7, :description => "Want to hone your spanish language skills in a socially fun and creative manner?  Come play games with us!  We have fun with a variety of board, table, and card games in small group settings, and all communication is in Spanish!  Doesn't matter what your current level of spanish is!  You will have fun and learn in a completely organic fashion. ")
  prison = FactoryGirl.create(:event, :title => "Movie and discussion: Prison Systems", :short_title => "Prison Discussion", :host => jared, :venue => house66, :start_time => (2.days.from_now), :end_time => (3.days.from_now + 3.hour), :min_attendees => 4, :max_attendees => 10, :description => "Come attend a coordinated movie + discussion of the California prison system. Prisons are an oft forgotten part of our society, and we will be exploring and discussing them in an open, shared, colloborative space.")
  
  # Some Attends
  (0..2).each { |i| drones[i].attends << sourdough; sourdough.create_activity(key: 'event.attend', owner: drones[i]) }
  (0..2).each { |i| drones[i].attends << parkour; parkour.create_activity(key: 'event.attend', owner: drones[i]) }
  (0..5).each { |i| drones[i].attends << throwies; throwies.create_activity(key: 'event.attend', owner: drones[i]) }
  jared.attends << spanish
  spanish.create_activity(key: 'event.attend', owner: jared)
  (0..2).each do |i|
    at = Attendance.new
    at.user = drones[i]
    at.event = spanish
    at.confirmed = [true, false, true].sample
    at.save!
    spanish.create_activity(key: 'event.attend', owner: at.user)
  end
  
end
