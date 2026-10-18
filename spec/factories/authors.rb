FactoryBot.define do
  factory :author do
    sequence(:name) { FFaker::Book.unique.author }
    sequence(:description) { FFaker::Book.unique.description }
  end
end
