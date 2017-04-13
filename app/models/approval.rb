class Approval < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  validates :approvable, :user, presence: true
end
