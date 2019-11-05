require 'import_jobs/_csv_citation_importer'

class CsvImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @imported_file = ImportedFile.find(args.first)

    import_citations_from_csv @imported_file

    ImportMailer.notify_import_completion(@imported_file.user.id, @imported_file.project.id).deliver_later
  end
end

