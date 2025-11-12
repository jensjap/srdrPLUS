FactoryBot.define do
  factory :type1_type do
    sequence(:name) { |n| "Type1 Type #{n}" }
  end
end
