FactoryGirl.define do
  factory :venue do
    name "Test Venue"
    association :owner, factory: :user
    location
  end
end
