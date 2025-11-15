FactoryBot.define do
  factory :extraction_forms_project_type do
    name { 'Standard' }

    # Use find_or_create to avoid uniqueness issues since these are specific values
    initialize_with { ExtractionFormsProjectType.find_or_create_by(name: name) }

    trait :diagnostic_test do
      name { 'Diagnostic Test' }
    end

    trait :mini_extraction do
      name { 'Mini Extraction' }
    end

    trait :citation_screening do
      name { 'Citation Screening Extraction Form' }
    end

    trait :fulltext_screening do
      name { 'Full Text Screening Extraction Form' }
    end
  end
end
