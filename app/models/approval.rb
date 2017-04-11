class Approval < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  def approve_now(user)
    update(user: user, approved_at: Time.current)
  end

  def approved?
    !approved_at.nil?
  end
end
