FactoryGirl.define do
  factory :user do
   email "test@villiagecraft.com"
   first_name "Test"
   last_name "user"
   password "foobar11"
   password_confirmation "foobar11"
  end
end
