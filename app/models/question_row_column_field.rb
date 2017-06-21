class QuestionRowColumnField < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :question_row_column_field_type, inverse_of: :question_row_column_fields
  belongs_to :question_row_column, inverse_of: :question_row_column_fields

  has_many :question_row_column_field_options, inverse_of: :question_row_column_field
end
