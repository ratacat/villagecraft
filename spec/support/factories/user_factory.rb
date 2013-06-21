FactoryGirl.define do
  factory :user do
   email "test@villiagecraft.com"
   name_first "Test"
   name_last "user"
   password "foobar11"
   password_confirmation "foobar11"
  end
end
