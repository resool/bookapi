FactoryBot.define do
  factory :member do
    sequence(:member_number) { |n| format("%06d", n) }
    sequence(:name) { FFaker::Name.name }
    sequence(:email) {  FFaker::Internet.unique.email }
    status { :active }
  end
end
