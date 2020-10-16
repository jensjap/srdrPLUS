namespace :extraction_tasks do
  desc "This removes all eefps that is associated with an 'Citation Screening Extraction Form' type efp"
  task remove_all_mini_extraction_eefps: [:environment] do
    ExtractionsExtractionFormsProjectsSection.left_joins( extraction_forms_projects_section: { extraction_forms_project: :extraction_forms_project_type } ).where(extraction_forms_projects_section: { extraction_forms_project: { extraction_forms_project_types: { name: "Citation Screening Extraction Form" } } }).destroy_all
  end
end

