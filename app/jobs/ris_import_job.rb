byebug

class RisImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user          = User.find( args.first )
    @project       = Project.find( args.second )
    @citation_file = @project.citation_files.find(args.third)

    import_citations_from_ris @project, args.third

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

