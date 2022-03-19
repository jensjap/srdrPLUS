class ImportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @imported_file = ImportedFile.find(args.first)
    @project = Project.find(@imported_file.project.id)
  end
end
