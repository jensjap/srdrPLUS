FactoryBot.define do
  factory :extraction_forms_projects_section_type do
    name { "Type1" }
    initialize_with { ExtractionFormsProjectsSectionType.find_or_create_by(name: name) }
  end
end
