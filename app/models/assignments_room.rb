class AssignmentsRoom < ApplicationRecord
  belongs_to :assignment
  belongs_to :room
end
