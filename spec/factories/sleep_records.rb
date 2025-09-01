FactoryBot.define do
  factory :sleep_record do
    user
    clock_in { Time.current }
    clock_out { nil }

    trait :completed do
      clock_out { clock_in + 8.hours }
    end

    trait :active do
      clock_in { 1.hour.ago }
      clock_out { nil }
    end
  end
end