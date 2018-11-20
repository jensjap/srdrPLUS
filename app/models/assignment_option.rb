class AssignmentOption < ApplicationRecord
  belongs_to :label_type, optional: true
  belongs_to :assignment
  belongs_to :assignment_option_type
end
