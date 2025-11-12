FactoryBot.define do
  factory :tps_comparisons_rssm do
    association :timepoint, factory: :extractions_extraction_forms_projects_sections_type1_row_column
    association :comparison
    association :result_statistic_sections_measure

    after(:create) do |tps_comparisons_rssm|
      # Create a polymorphic record entry
      create(:record, recordable: tps_comparisons_rssm, name: '75.5')
    end
  end
end
