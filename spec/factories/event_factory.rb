FactoryGirl.define do
  factory :event do
    title "Test Event"
    description { HipsterIpsumHelpers.generate }
    min_attendees 10
    max_attendees 20
    price 0
    
    after(:create) { |event| event.create_activity(:create, owner: event.host) }
    
    factory :event_with_meetings do
      ignore do
        start_time { Timeliness.parse("#{(rand(60) + 1).days.from_now.to_date} #{(7..21).to_a.sample}:00") }
        duration { [30, 60, 90, 120].sample.minutes }
        meetings_per_rerun 1
        time_between_meetings { 1.day }
        venue nil
      end
      
      after(:create) do |event, evaluator|
        evaluator.meetings_per_rerun.times do |i|
          FactoryGirl.create(:meeting,
                              event: event, 
                              start_time: evaluator.start_time + i * evaluator.time_between_meetings,
                              end_time: evaluator.start_time + i * evaluator.time_between_meetings + evaluator.duration,
                              venue: evaluator.venue)
        end
      end
    end
  end
end
