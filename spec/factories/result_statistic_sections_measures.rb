FactoryBot.define do
  factory :result_statistic_sections_measure do
    association :result_statistic_section
    association :measure
    sequence(:pos) { |n| n }

    trait :with_data do
      after(:create) do |rssm|
        # Create TpsArmsRssm (descriptive statistics data)
        create(:tps_arms_rssm, result_statistic_sections_measure: rssm)
      end
    end

    trait :with_diagnostic_test_data do
      after(:create) do |rssm|
        # Create TpsComparisonsRssm (diagnostic test data)
        create(:tps_comparisons_rssm, result_statistic_sections_measure: rssm)
      end
    end

    trait :with_comparison_data do
      after(:create) do |rssm|
        # Create ComparisonsArmsRssm (comparison data)
        create(:comparisons_arms_rssm, result_statistic_sections_measure: rssm)
      end
    end

    trait :dependent do
      association :result_statistic_sections_measure, factory: :result_statistic_sections_measure
    end
  end
end
