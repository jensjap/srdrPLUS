class CreateAndUpdatePublicationRemindersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # To create publication reminder the project must satisfy the following conditions:
    # 1. Contain 5 or more Extractions
    # 2. Neither the Project nor the youngest Extraction has been edited in the last 6 months

    PublicationReminder.check_projects_for_reminders
  end
end