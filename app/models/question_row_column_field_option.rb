class QuestionRowColumnFieldOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :question_row_column_field, inverse_of: :question_row_column_field_options
end
