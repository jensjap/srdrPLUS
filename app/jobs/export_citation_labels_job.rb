class ExportCitationLabels < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"
  end
end
