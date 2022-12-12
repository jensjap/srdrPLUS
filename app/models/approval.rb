# == Schema Information
#
# Table name: approvals
#
#  id              :integer          not null, primary key
#  approvable_type :string(255)
#  approvable_id   :integer
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Approval < ApplicationRecord
  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  validates :approvable, :user, presence: true

  after_create :notify_publisher

  private

  def notify_publisher
    publishing = approvable
    email_of_publisher = publishing.user.email
    title = publishing.publishable.display
    type = publishing.name_of_pub_type
    publishing_id = publishing.id
    PublishingMailer.notify_publisher_of_approval(email_of_publisher, title, type, publishing_id,
                                                  publishing.publishable.id).deliver_later
  end
end
