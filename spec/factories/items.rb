FactoryBot.define do
  factory :item do
    edition
    sequence(:sku) { |n| SecureRandom.random_number(1000000).to_s.rjust(6, "0") }
    condition { "new" }
    status { :available }
  end
end
