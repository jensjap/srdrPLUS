FactoryBot.define do
  factory :extraction_forms_projects_section_type do
    sequence(:name) { |n| "Type #{n}" }
  end
end
