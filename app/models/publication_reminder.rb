class PublicationReminder < ApplicationRecord
  include PublicationReminderHelper

  belongs_to :user
  belongs_to :project
end
