require 'mysql2'

def _db
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_production'])
end

def _find_project(project_id)
  return Project.find(project_id)
end

namespace(:skeleton_import_tasks) do
  namespace(:import_data_set) do
    desc "Import skeleton spreadsheet."
    task :process_spreadsheet, [:project_id] => [:environment] do |t, args|
      # Ensure task was called with proper arguments.
      begin
        @project = _find_project(args.project_id.to_i)
        Rails.logger.debug("Import data set for project ID #{ args.project_id } requested. Found and processing the following project ID #{ @project.id }: \"#{ @project.name }\"")
      rescue
        Rails.logger.fatal("Unable to retrieve Project. Check that project ID was properly provided.")
      end
    end  # END task :process_spreadsheet, [:project_id] => [:environment] do |t, args|
  end  # END namespace(:import_data_set) do
end  # END namespace(:skeleton_import_tasks) do
