FactoryBot.define do
  factory :edition do
    work
    sequence(:title) { |n| "Edition #{n}" }
    description { FFaker::Book.unique.description }
    publisher { FFaker::Company.name }
    published_year { (1950..Date.current.year).to_a.sample }
    sequence(:isbn) { FFaker::Book.unique.isbn }
  end
end
