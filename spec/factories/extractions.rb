FactoryBot.define do
  factory :extraction do
    citations_project
    project { citations_project.project }
    # Add other required attributes here
  end
end
