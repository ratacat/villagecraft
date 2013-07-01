FactoryGirl.define do
  sequence :email do |n|
    "seed#{n}@example.com"
  end

  factory :user do
   email
   first_name "Test"
   last_name "User"
   password "foobar11"
   password_confirmation "foobar11"
   location
  end
  
end
