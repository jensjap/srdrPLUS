FactoryBot.define do
  factory :extraction_forms_projects_section do
    association :extraction_forms_project
    association :extraction_forms_projects_section_type

    section do
      Section.find_or_create_by!(name: "Test Section #{SecureRandom.hex(4)}") do |s|
        s.default = false
      end
    end

    hidden { false }
    sequence(:pos)
  end
end
