require 'spec_helper'

feature "signing up" do
  before do
    visit '/'
    click_link "Sign Up"
  end

  scenario "A new user can sign up" do
    fill_in "Email", :with => "test@villagecraft.com"
    fill_in "First Name", :with => "Test"
    fill_in "Last Name", :with => "User"
    fill_in "Password", :with => "foobar11"
    fill_in "Password confirmation", :with => "foobar11"
    click_button "Sign up"
    page.should have_content("Welcome! You have signed up successfully.")
  end

  scenario "cannot sign up with invalid data" do
    fill_in "Email", :with => ""
    fill_in "First Name", :with => ""
    fill_in "Last Name", :with => ""
    fill_in "Password", :with => ""
    fill_in "Password confirmation", :with => ""
    click_button "Sign up"
    page.should have_content("Some errors were found, please take a look:")
    page.should have_content("can't be blank")
  end
end
