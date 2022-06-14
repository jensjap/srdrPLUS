require 'import_jobs/_ris_citation_importer'

class RisImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later

    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
    imported_file = ImportedFile.find(args.first)
    import_citations_from_ris imported_file
    ImportMailer.notify_import_completion(imported_file.id).deliver_later
  rescue StandardError => e
    ImportMailer.notify_import_failure(imported_file.id, e.message).deliver_later
  end
end
