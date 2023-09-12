module PublicationReminderHelper
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def check_projects_for_reminders
      projects_of_concern.each do |project|
        project.leaders.each do |user|
          PublicationReminder.transaction do
            if (reminder = PublicationReminder.find_by(user:, project:))
              # A PublicationReminder record exists, therefore we send 2nd reminder
              # Send 2nd reminder email if reminder.active=true
              # and set active=false.
              PublicationReminderMailer.second_reminder(user.id, project.id).deliver_now if reminder.active
              reminder.update(active: false)

            else
              # No PublicationReminder exists, therefore we create PublicationReminder,
              # send 1st reminder email and set active=true
              PublicationReminder.create(user:, project:, active: true)
              # Send 1st reminder email
              PublicationReminderMailer.first_reminder(user.id, project.id).deliver_now

            end
          end
        end
      end
    end

    private

    # To create publication reminder the project must satisfy the following conditions:
    # 1. Contain 5 or more Extractions
    # 2. Neither the Project nor the youngest Extraction has been edited in the last 6 months
    def projects_of_concern
      Extraction
        .select('project_id').group('project_id').having('count(*) > ?', 4)
        .map { |group| Project.find(group.project_id) }
        .select do |project|
          project.extractions.all? do |extraction|
            extraction.updated_at < 6.months.ago
          end && !project.public? && project.updated_at < 6.months.ago
        end
    end
  end
end
