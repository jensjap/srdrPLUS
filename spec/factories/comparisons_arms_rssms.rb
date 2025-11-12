FactoryBot.define do
  factory :comparisons_arms_rssm do
    association :comparison
    association :extractions_extraction_forms_projects_sections_type1_row, factory: :extractions_extraction_forms_projects_sections_type1_row
    association :result_statistic_sections_measure

    after(:create) do |comparisons_arms_rssm|
      # Create a polymorphic record entry
      create(:record, recordable: comparisons_arms_rssm, name: '0.05')
    end
  end
end
