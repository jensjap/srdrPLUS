class QuestionRowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :question_row, inverse_of: :question_row_columns

  has_many :question_row_column_fields, inverse_of: :question_row_column
end
