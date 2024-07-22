class ProjectCloningService
  def self.clone_project(project, leaders, opts)
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

    copied_project
  end
end
