FactoryGirl.define do
  factory :event do
    title "Test Event"
    short_title { title.split[0,2].join(' ') }
    description "this is an event for testing purposes or porpoises"
    start_time { Timeliness.parse("#{(rand(60) + 1).days.from_now.to_date} #{(7..21).to_a.sample}:00") }
    end_time { start_time + [30, 60, 90, 120].sample.minutes }
    min_attendees 10
    max_attendees 20
    after(:create) { |event| event.create_activity(:create, owner: event.host) }
  end
end
