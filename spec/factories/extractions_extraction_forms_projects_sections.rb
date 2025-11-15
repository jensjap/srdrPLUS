FactoryBot.define do
  factory :extractions_extraction_forms_projects_section do
    association :extraction
    association :extraction_forms_projects_section
  end

  # Type1 is a different class - not nested to avoid inheritance
  factory :extractions_extraction_forms_projects_sections_type1, class: 'ExtractionsExtractionFormsProjectsSectionsType1' do
    association :extractions_extraction_forms_projects_section
    association :type1_type

    transient do
      type1_name { "Outcome #{SecureRandom.hex(8)}" }
    end

    type1 do
      Type1.find_or_create_by!(name: type1_name) do |t|
        t.description = "Test outcome"
      end
    end
  end
end
