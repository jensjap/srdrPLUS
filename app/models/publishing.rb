class Publishing < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :publishable, polymorphic: true
  belongs_to :approved_by, class_name: 'User', inverse_of: :publishing_approvals, optional: true
  belongs_to :requested_by, class_name: 'User', inverse_of: :publishing_requests
end
