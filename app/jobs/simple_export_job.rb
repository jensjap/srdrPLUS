class SimpleExportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find(args.first)
    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"
  end
end
