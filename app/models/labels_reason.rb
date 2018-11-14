class LabelsReason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :label
  belongs_to :reason
end
