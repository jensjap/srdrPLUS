class DistillerImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @project = Project.find( args.first )
    @user = User.find( args.second )


    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

