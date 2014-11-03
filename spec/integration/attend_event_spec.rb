require "spec_helper"

feature "attend an event" do
  let!(:user) {Factory(:user)}
  let!(:event) {Factory(:event, :host => user)}

  before do
    visit '/'
    sign_in_as!(user)
    click_link "My Events"
    click_link event.short_title
  end

  scenario "attending an event" do
    click_link "Attend"
    page.should have_content("You will attend!")
  end

  scenario "unattending an event" do
    click_link "Attend"
    page.should have_content("You will attend!")
    click_link "cancel"
    page.should have_content("Your attendence has been canceled")
  end
end
