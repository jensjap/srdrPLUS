class CitationFhirImportJob < ApplicationJob
  queue_as :default

  # @parms [Array<Integer>] imported_file_id, user_id
  def perform(*args)
    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"

    imported_file_id = args[0]
    user_id = args[1]
    import_id = args[2]
    @imported_file = ImportedFile.find(imported_file_id)

    begin
      json = JSON.parse(@imported_file.content.download)
    rescue StandardError
      Rails.logger.debug "Cannot parse file as JSON: #{@imported_file}"
      return
    end

    json.each do |citation_json|
      citation_fhir_importer = ImportJobs::JsonImportJob::CitationFhirImporter.new(@imported_file.project.id, citation_json, user_id, import_id)
      citation_fhir_importer.run
    end

    ImportMailer.notify_import_completion(@imported_file.user.id, @imported_file.project.id).deliver_later
  end
end
