FactoryBot.define do
  factory :population_name do
    sequence(:name) { |n| "Population #{n}" }
    description { "Test population description" }
  end
end
