require "spec_helper"

feature "creating an event" do
  let!(:user) {Factory(:user)}
  
  before do
    sign_in_as!(user)
    visit '/'
    click_link "My Events"
    click_link "New Event"
  end
  
  scenario "a user can create an event" do
    fill_in "Title", :with => "My new event"
    fill_in "Short Title", :with => "New Event"
    fill_in "Min attendees", :with => "10"
    fill_in "Max attendees", :with => "100"
    fill_in "Date", :with => Date.today+1
    fill_in "Start Time", :with => "12:00 PM"
    fill_in "End Time", :with => "1:00 PM"
    fill_in "Description", :with => "this is a test event"
    click_button "Create Event"
    page.should have_content("Event was successfully created.")
  end

  scenario "a user can't create an event in the past" do
    fill_in "Title", :with => "My new event"
    fill_in "Short Title", :with => "New Event"
    fill_in "Min attendees", :with => "10"
    fill_in "Max attendees", :with => "100"
    fill_in "Date", :with => "1986-10-11"
    fill_in "Start Time", :with => "12:00 PM"
    fill_in "End Time", :with => "1:00 PM"
    fill_in "Description", :with => "this is a test event"
    click_button "Create Event"
    page.should have_content("Some errors were found, please take a look:")
    page.should have_content("Date can't be in the past")
  end

  scenario "an event can't end before it begins" do
    fill_in "Title", :with => "My new event"
    fill_in "Short Title", :with => "New Event"
    fill_in "Min attendees", :with => "10"
    fill_in "Max attendees", :with => "100"
    fill_in "Date", :with => Date.today+1
    fill_in "Start Time", :with => "2:00 PM"
    fill_in "End Time", :with => "1:00 PM"
    fill_in "Description", :with => "this is a test event"
    click_button "Create Event"
    page.should have_content("Some errors were found, please take a look:")
    page.should have_content("must be after 14:00")
  end
end
