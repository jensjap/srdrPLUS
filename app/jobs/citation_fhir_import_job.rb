require 'import_jobs/json_import_job/_citation_fhir_importer'

class CitationFhirImportJob < ApplicationJob
  queue_as :default

  # @parms [Array<Integer>] imported_file_id
  def perform(*args)
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    imported_file_id = args[0]
    @imported_file = ImportedFile.find(imported_file_id)

    begin
      json = JSON.parse(@imported_file.content.download)
    rescue
      Rails.logger.debug "Cannot parse file as JSON: #{@imported_file}"
      return
    end

    json.each do |citation_json|
      citation_fhir_importer = CitationFhirImporter.new(@imported_file.project.id, citation_json)
      citation_fhir_importer.run
    end

    ImportMailer.notify_import_completion(@imported_file.user.id, @imported_file.project.id).deliver_later
  end
end
