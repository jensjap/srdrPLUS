class FollowupField < ApplicationRecord
  belongs_to :question_row_column_question_row_column_option, inverse_of: :followup_fields

  has_many :extractions_followup_fields, dependent: :destroy, inverse_of: :followup_field
  has_many :dependencies, as: :prerequisitable, dependent: :destroy
end
