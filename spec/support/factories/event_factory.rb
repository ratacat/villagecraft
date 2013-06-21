FactoryGirl.define do
  factory :event do
    title "My new Event"
    short_title "event"
    description "this is an event for testing purposes or porpoises"
    date "2199-01-01"
    start_time_time "12:15 PM"
    end_time_time  "1:15 PM"
    min_attendees 10
    max_attendees 20
  end
end
