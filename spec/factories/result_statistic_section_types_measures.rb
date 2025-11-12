FactoryBot.define do
  factory :result_statistic_section_types_measure do
    association :result_statistic_section_type
    association :measure
    default { false }

    trait :default_measure do
      default { true }
    end

    trait :with_provider do
      association :result_statistic_section_types_measure, factory: :result_statistic_section_types_measure
    end
  end
end
