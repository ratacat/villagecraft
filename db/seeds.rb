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
  ravenhaus_loc = FactoryGirl.create(:location, :street => "1540 Prince St", :city => "Berkeley", :state_code => "CA")
  
  # Some Users
  images_path = Rails.root.join('spec', 'support', 'images')

  jared = FactoryGirl.create(:user, :name => "Jared Smith", :email => "jared@example.com", :location => berkeley, :profile_image => File.open(images_path.join('jared.jpg')), :phone => '+14065299748', :host => true, :admin => true)
  ben = FactoryGirl.create(:user, :name => "Ben Teitelbaum", :email => "ben@example.com", :location => oakland, :profile_image => File.open(images_path.join('ben.jpg')), :phone => '+14156253216', :host => true, :admin => true)
  jared.update_attribute :admin, true
  ben.update_attribute :admin, true
  
  jwz = FactoryGirl.create(:user, :name => "Jamie Zawinski", :email => "jwz@example.com", :location => sf, :profile_image => File.open(images_path.join('jamie.jpg')))
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
  ravenhaus = FactoryGirl.create(:venue, :name => "Ravenhaus", :owner => jared, :location => ravenhaus_loc)

  # Some Workshops, Events, and Meetings
  sourdough  = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                  :title => "Sourdough Bread Class", 
                                  :host => jared,
                                  :venue => jareds_house,
                                  :reruns_per_workshop => 3,
                                  :description => "Sourdough has been used since the invention of bread to cultivate and encourage wild yeasts that occur in everything to help make delicious, fluffy, sour bread. The distinctive sour taste comes from the cultivated family of lactobacillus bacteria and yeasts. These tiny lifeforms have long since allied themselves as human digestive flora.  Bread that is cultured with lactobacillus is easier to digest then commercial bakers yeast.<br><br>Please bring a small bread pan, clothing that can get flour on it. And anything you want to spread on your bread.  You will learn the entire process from beginning to end, and everyone gets to take a fresh loaf of bread home. (also some of your very own starter)")
  parkour    = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                  :title => "Parkour & Movement Training", 
                                  :host => jared,
                                  :venue => sproul,
                                  :start_time => (1.days.from_now + 5.hours),
                                  :description => "Parkour is the art and science of efficient movement over and through obstacles. This class is an adult basics, suitable for all ages above 18. We will be using simple progressive techniques to learn a huge variety of playful and practical abilities. All body types are encouraged!  Parkour is an individual practice, which means you work to become comfortable with and expand your own abilities in a safe and supportive environment.")
  throwies   = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                  :title => "Small Business Social Media Training", 
                                  :host => ben,
                                  :venue => bens_house,
                                  :price => 25,
                                  :reruns_per_workshop => 3,
                                  :meetings_per_rerun => 3,
                                  :start_time => (5.hours.from_now),
                                  :description => "Remember the old maxim 'Location! Location! Location!'?  As we usher in the information age, this saying has never been more relevant.  Except now it's referring to less your physical location, and more to the location of your business listings!  People explore their cities with their cellphones!  And the better off your positions, the more feet you get in your door.  This class is targetted to Small Business owners that are looking to take their future into their own hands. You don't need to be an uber nerd to learn more about how to build your business a better digital location.")
  spanish   = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                 :title => "Practice your Spanish by playing board games!", 
                                 :host => ben,
                                 :venue => bens_house,
                                 :start_time => (3.days.from_now),
                                 :description => "Want to hone your spanish language skills in a socially fun and creative manner?  Come play games with us!  We have fun with a variety of board, table, and card games in small group settings, and all communication is in Spanish!  Doesn't matter what your current level of spanish is!  You will have fun and learn in a completely organic fashion. ")
  prison    = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                 :title => "Movie and discussion: Prison Systems", 
                                 :host => jared,
                                 :venue => house66, 
                                 :start_time => (2.days.from_now), 
                                 :duration => 3.hours,
                                 :description => "Come attend a coordinated movie + discussion of the California prison system. Prisons are an oft forgotten part of our society, and we will be exploring and discussing them in an open, shared, colloborative space.")
  coffee_desc = %q(
Come learn the joys of coldpressing your coffee!
<dl>
  <dt>What to expect</dt>
  <dd>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</dd>
  <dt>What to bring</dt>
  <dd>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</dd>  
</dl>
)
  coffee      = FactoryGirl.create(:workshop_with_reruns_and_meetings, 
                                   :title => "Coldpressed Coffee", 
                                   :host => jared, 
                                   :venue => ravenhaus, 
                                   :start_time => (3.days.from_now), 
                                   :duration => 3.hours,
                                   :description => coffee_desc)
  
  # Some Attends (each user attends four random events)
  (drones + [jared, ben, jwz]).each do |user|
    Event.all.sample(4).each do |event|
      user.attends << event
      event.create_activity(key: 'event.attend', owner: user)
    end
  end
  
end
