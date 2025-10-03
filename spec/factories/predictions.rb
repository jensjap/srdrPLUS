FactoryBot.define do
  factory :prediction do
    citations_project
    project { citations_project.project }
    # Add other required attributes here
  end
end
