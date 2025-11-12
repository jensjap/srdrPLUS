FactoryBot.define do
  factory :extraction_form do
    sequence(:name) { |n| "Extraction Form #{n}" }
  end
end
