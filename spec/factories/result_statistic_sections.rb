FactoryBot.define do
  factory :result_statistic_section do
    transient do
      rsst_name { nil }
    end

    # Default: create population and type, then find the auto-created RSS
    after(:create) do |rss, evaluator|
      # If population creates default RSSs, they're already created now
    end

    trait :descriptive do
      transient do
        rsst_name { 'Descriptive Statistics' }
      end

      # Create population first, which will auto-create the RSS we need
      population { create(:extractions_extraction_forms_projects_sections_type1_row) }

      # Find the auto-created RSS with this type
      initialize_with do
        rsst = ResultStatisticSectionType.find_or_create_by!(name: rsst_name)
        pop = population || create(:extractions_extraction_forms_projects_sections_type1_row)
        pop.result_statistic_sections.find_by!(result_statistic_section_type: rsst)
      end
    end

    trait :between_arm_comparison do
      transient do
        rsst_name { 'Between Arm Comparisons' }
      end

      population { create(:extractions_extraction_forms_projects_sections_type1_row) }

      initialize_with do
        rsst = ResultStatisticSectionType.find_or_create_by!(name: rsst_name)
        pop = population || create(:extractions_extraction_forms_projects_sections_type1_row)
        pop.result_statistic_sections.find_by!(result_statistic_section_type: rsst)
      end
    end

    trait :diagnostic_test_descriptive do
      transient do
        rsst_name { 'Diagnostic Test Descriptive Statistics' }
      end

      population { create(:extractions_extraction_forms_projects_sections_type1_row) }

      initialize_with do
        rsst = ResultStatisticSectionType.find_or_create_by!(name: rsst_name)
        pop = population || create(:extractions_extraction_forms_projects_sections_type1_row)
        pop.result_statistic_sections.find_by!(result_statistic_section_type: rsst)
      end
    end
  end
end
