FactoryBot.define do
  factory :loan do
    item
    member
    rented_at { Time.current }
    due_at { 2.weeks.from_now }

    trait :returned do
      returned_at { 1.day.from_now }
    end

    trait :active do
      returned_at { nil }
      due_at { 2.weeks.from_now }
    end

    trait :overdue do
      rented_at { 3.weeks.ago }
      due_at { 1.week.ago }
    end
  end
end
