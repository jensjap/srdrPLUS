class LabelsReason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :label, inverse_of: :labels_reasons
  belongs_to :reason, inverse_of: :labels_reasons
  belongs_to :projects_users_role

  accepts_nested_attributes_for :reason
end
