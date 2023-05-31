# == Schema Information
#
# Table name: publication_reminders
#
#  id         :bigint           not null, primary key
#  user_id    :integer          not null
#  project_id :integer          not null
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PublicationReminder < ApplicationRecord
  include PublicationReminderHelper

  belongs_to :user
  belongs_to :project
end
