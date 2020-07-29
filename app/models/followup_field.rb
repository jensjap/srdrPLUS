class FollowupField < ApplicationRecord
  acts_as_paranoid
  belongs_to :question_row_columns_question_row_column_option, inverse_of: :followup_field

  has_many :extractions_extraction_forms_projects_sections_followup_fields, dependent: :destroy, inverse_of: :followup_field
  has_many :dependencies, as: :prerequisitable, dependent: :destroy
end
