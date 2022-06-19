class JsonImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"

    @json_file = ImportedFile.find(args.first)

    begin
      fhash = JSON.parse(@json_file.content.download)
    rescue StandardError
      Rails.logger.debug "Cannot parse file as JSON: #{@json_file}"
      return
    end

    phash = fhash['project']

    if phash.nil?
      Rails.logger.debug "Cannot find 'project' in JSON"
      return
    end

    project_importer = ImportJobs::JsonImportJob::ProjectImporter.new(@project)
    project_importer.import_project(phash)

    ImportMailer.notify_import_completion(@imported_file.user.id, @imported_file.project.id).deliver_later
  end
end
