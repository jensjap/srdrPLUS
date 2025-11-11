FactoryBot.define do
  factory :degree do
    sequence(:name) { |n| "Degree #{n}" }
  end
end
