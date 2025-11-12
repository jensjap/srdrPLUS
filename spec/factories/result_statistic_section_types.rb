FactoryBot.define do
  factory :result_statistic_section_type do
    sequence(:name) { |n| "Result Statistic Section Type #{n}" }

    trait :descriptive do
      name { 'Descriptive Statistics' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'Descriptive Statistics') }
    end

    trait :between_arm_comparison do
      name { 'Between Arm Comparisons' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'Between Arm Comparisons') }
    end

    trait :within_arm_comparison do
      name { 'Within Arm Comparisons' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'Within Arm Comparisons') }
    end

    trait :net_change do
      name { 'NET Change' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'NET Change') }
    end

    trait :diagnostic_test_descriptive do
      name { 'Descriptive Statistics (Diagnostic Test)' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'Descriptive Statistics (Diagnostic Test)') }
    end

    trait :diagnostic_test_auc do
      name { 'AUC and qStar' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'AUC and qStar') }
    end

    trait :diagnostic_test_2x2 do
      name { '2x2 Table' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: '2x2 Table') }
    end

    trait :diagnostic_test_accuracy do
      name { 'Test Accuracy Metrics' }
      initialize_with { ResultStatisticSectionType.find_or_create_by(name: 'Test Accuracy Metrics') }
    end
  end
end
