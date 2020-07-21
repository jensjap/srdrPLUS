# == Schema Information
#
# Table name: approvals
#
#  id              :integer          not null, primary key
#  approvable_type :string(255)
#  approvable_id   :integer
#  user_id         :integer
#  deleted_at      :datetime
#  active          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Approval < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  validates :approvable, :user, presence: true

  after_create :notify_publisher

  private
    def notify_publisher
      publishing = self.approvable
      type = publishing.name_of_pub_type
      email_of_publisher = publishing.user.email
      id = publishing.publishable_id
      title = publishing.publishable.report_title
      PublishingMailer.notify_publisher_of_approval(email_of_publisher, title, type, id).deliver_later
    end
end
