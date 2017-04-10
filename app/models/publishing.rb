class Publishing < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :publishable, polymorphic: true
  belongs_to :approved_by, class_name: 'User', inverse_of: :publishing_approvals, optional: true
  belongs_to :requested_by, class_name: 'User', inverse_of: :publishing_requests

  validates :requested_by_id, presence: true

  def approve_now(user)
    update(approved_by: user, approved_at: Time.current)
  end

  def approved?
    !approved_at.nil?
  end
end
