require 'spec_helper'

feature "sign in as an existing user" do
  let!(:user) {Factory(:user)}
  before do
    visit '/'
  end

  scenario "user can sign in " do
    click_link "Log In"
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    click_button "Sign in"
    page.should have_content("Signed in successfully.")
  end
end

