class ProjectCloningService
  def self.clone_project(project, copy_extractions: false, leaders: [])
    leaders << User.find(2) if leaders.blank?

    project.amoeba_copy_extractions = copy_extractions
    copied_project = project.amoeba_dup
    copied_project.create_empty = true
    copied_project.is_amoeba_copy = true
    copied_project.save
    leaders.each do |leader|
      copied_project.projects_users.create(user: leader, permissions: 1)
    end

    copied_project
  end
end
