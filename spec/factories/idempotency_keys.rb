FactoryBot.define do
  factory :idempotency_key do
    sequence(:key) { |n| "key-#{n}" }
    request_fingerprint { Digest::SHA256.hexdigest("request") }

    trait :completed do
      response_status { 201 }
      response_body { '{"data":{}}' }
    end
  end
end
