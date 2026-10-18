FactoryBot.define do
  factory :item do
    edition
    sequence(:sku) { |n| format("%06d", n) }
    condition { "new" }
    status { :available }
  end
end
