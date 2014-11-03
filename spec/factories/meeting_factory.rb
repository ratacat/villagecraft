FactoryGirl.define do
  factory :meeting do
    start_time { Timeliness.parse("#{(rand(60) + 1).days.from_now.to_date} #{(7..21).to_a.sample}:00") }
    end_time { start_time + [30, 60, 90, 120].sample.minutes }
    snippet ''
  end
end
