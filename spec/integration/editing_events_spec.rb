require 'spec_helper'

feature "edit an event" do
  let!(:user) {Factory(:user)}
  let!(:event) {Factory(:event, :host => user)}

  before do
    visit '/'
    sign_in_as!(user)
    click_link "My Events"
    click_link event.short_title
    click_link "Edit"
  end

  scenario "Edit an event" do
    fill_in "Title", :with => "Some new event"
    fill_in "Date", :with => "2199-01-01"
    click_button "Update Event"
    page.should have_content("Event was successfully updated")
  end

  scenario "Edit an event with an old date" do
    fill_in "Date", :with => "1984-01-01"
    click_button "Update Event"
    page.should have_content("Some errors were found, please take a look:")
    page.should have_content("Date can't be in the past")
  end

  scenario "an event that ends before it starts" do
    fill_in "Start Time", :with => "3:00 PM"
    fill_in "End Time", :with => "2:00 PM"
    click_button "Update Event"
    page.should have_content("Some errors were found, please take a look:")
    page.should have_content("must be after 15:00:00")
  end

end
