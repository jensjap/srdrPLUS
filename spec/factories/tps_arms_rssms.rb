FactoryBot.define do
  factory :tps_arms_rssm do
    association :timepoint, factory: :extractions_extraction_forms_projects_sections_type1_row_column
    association :extractions_extraction_forms_projects_sections_type1
    association :result_statistic_sections_measure

    after(:create) do |tps_arms_rssm|
      # Create a polymorphic record entry
      create(:record, recordable: tps_arms_rssm, name: '42')
    end
  end
end
