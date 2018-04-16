class QuestionRowColumnOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :question_row_columns_question_row_column_options, dependent: :destroy, inverse_of: :question_row_column_option
  has_many :question_row_columns, through: :question_row_columns_question_row_column_options, dependent: :destroy
end
