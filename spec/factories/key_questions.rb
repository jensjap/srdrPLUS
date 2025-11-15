FactoryBot.define do
  factory :key_question do
    sequence(:name) { |n| "Key Question #{n}" }
  end
end
