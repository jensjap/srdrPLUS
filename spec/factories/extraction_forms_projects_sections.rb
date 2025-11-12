FactoryBot.define do
  factory :extraction_forms_projects_section do
    association :extraction_forms_project
    association :extraction_forms_projects_section_type
    association :section
    hidden { false }
    pos { 1 }
  end
end
