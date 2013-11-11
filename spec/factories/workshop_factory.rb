FactoryGirl.define do
  factory :workshop do
    title "Test Workshop"
    description "This is a test workshop for testing purposes or porpoises"
    
    factory :workshop_with_reruns_and_meetings do
      ignore do
        start_time { Timeliness.parse("#{(rand(60) + 1).days.from_now.to_date} #{(7..21).to_a.sample}:00") }
        duration { [30, 60, 90, 120].sample.minutes }
        reruns_per_workshop 1
        time_between_reruns { 1.week }
        meetings_per_rerun 1
        venue nil
        price 0
      end

      after(:create) do |workshop, evaluator|
        evaluator.reruns_per_workshop.times do |i|
          FactoryGirl.create(:event_with_meetings,
                              title: evaluator.title,
                              host: evaluator.host,
                              description: evaluator.description,
                              workshop: workshop, 
                              start_time: evaluator.start_time + i * evaluator.time_between_reruns,
                              duration: evaluator.duration, 
                              venue: evaluator.venue,
                              price: evaluator.price,
                              meetings_per_rerun: evaluator.meetings_per_rerun)
        end
      end
    end
  end
end
