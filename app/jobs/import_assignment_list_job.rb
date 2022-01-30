class ImportAssignmentListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    project_id = args.first
    @project = Project.find(project_id)
    debugger
  end
end
