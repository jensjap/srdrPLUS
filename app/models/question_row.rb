class QuestionRow < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, inverse_of: :question_row
end
