# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    body "MyString"
    user_id 1
    event_id 1
  end
end
