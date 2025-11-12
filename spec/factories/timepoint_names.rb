FactoryBot.define do
  factory :timepoint_name do
    sequence(:name) { |n| "Timepoint #{n}" }
  end
end
