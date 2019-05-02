require "import_jobs/_pubmed_citation_importer"

class PubmedImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user          = User.find( args.first )
    @project       = Project.find( args.second )
    @imported_file = ImportedFile.find(args.third)

    import_citations_from_pubmed_file @imported_file

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end
