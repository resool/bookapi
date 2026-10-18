FactoryBot.define do
  factory :work do
    sequence(:title) { |n|  FFaker::Book.unique.title }
  end
end
