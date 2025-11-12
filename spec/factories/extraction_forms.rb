FactoryBot.define do
  factory :extraction_form do
    sequence(:name) { |n| "Extraction Form #{n} #{SecureRandom.hex(4)}" }
  end
end
