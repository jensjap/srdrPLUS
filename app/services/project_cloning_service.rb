class ProjectCloningService
  def self.clone_project(project, leaders = [], opts = {})
    leaders << User.find(2) if leaders.blank?

    amoeba_copy_citations = opts[:include_citations] || false
    amoeba_copy_extraction_forms = opts[:include_extraction_forms] || false
    amoeba_copy_extractions = opts[:include_extractions] || false
    amoeba_copy_labels = opts[:include_labels] || false

    project.amoeba_copy_citations = amoeba_copy_citations
    project.amoeba_copy_extraction_forms = amoeba_copy_extraction_forms
    project.amoeba_copy_extractions = amoeba_copy_extractions
    project.amoeba_copy_labels = amoeba_copy_labels

    copied_project = project.amoeba_dup
    copied_project.create_empty = false
    copied_project.is_amoeba_copy = true
    copied_project.save

    leaders.each do |leader|
      copied_project.projects_users.create(
        user: leader,
        permissions: 1
      )
    end

    if amoeba_copy_extractions
      # Assign all extractions to the first leader.
      copied_project.extractions.each do |extraction|
        extraction.update(user: leaders.first)
      end
    end

    # debugger

    copied_project
  end

  def self.find_unique_comparisons(project)
    Comparison
      .joins(comparisons_result_statistic_sections: { result_statistic_section: { population: { extractions_extraction_forms_projects_sections_type1: { extractions_extraction_forms_projects_section: :extraction } } } })
      .where(extractions: { project_id: project.id })
      .distinct
  end
end
