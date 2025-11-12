FactoryBot.define do
  factory :comparison do
    sequence(:name) { |n| "Comparison #{n}" }
  end
end
