require 'import_jobs/json_import_job/_project_importer'

class JsonImportJob < ApplicationJob
  queue_as :default

  # @param [Array<Integer>] imported_file_id
  def perform(*args)
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    imported_file_id = args.first
    @json_file = ImportedFile.find(imported_file_id)

    begin
      fhash = JSON.parse(@json_file.content.download)
debugger
    rescue
      Rails.logger.debug "Cannot parse file as JSON: #{@json_file}"
      return
    end

    phash = fhash["project"]

    if phash.nil?
      Rails.logger.debug "Cannot find 'project' in JSON"
      return
    end

    project_importer = ProjectImporter.new(@project)
    project_importer.import_project(phash)

    ImportMailer.notify_import_completion(@imported_file.user.id, @imported_file.project.id).deliver_later
  end
end
