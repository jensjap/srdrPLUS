FactoryBot.define do
  factory :extraction_forms_project do
    association :extraction_form
    association :project
    association :extraction_forms_project_type
    public { false }

    # Skip callbacks that require complex setup (sections, arms, etc.)
    after(:build) do |efp|
      efp.create_empty = true
    end
  end
end
