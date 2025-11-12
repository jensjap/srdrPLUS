FactoryBot.define do
  factory :extractions_extraction_forms_projects_sections_type1_row do
    association :extractions_extraction_forms_projects_sections_type1
    association :population_name

    trait :with_timepoints do
      after(:create) do |row|
        create(:extractions_extraction_forms_projects_sections_type1_row_column,
               extractions_extraction_forms_projects_sections_type1_row: row,
               timepoint_name: create(:timepoint_name, name: "Baseline #{SecureRandom.hex(4)}"))
      end
    end
  end
end
