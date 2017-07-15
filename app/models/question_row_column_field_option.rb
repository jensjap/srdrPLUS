class QuestionRowColumnFieldOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :question_row_column_fields_question_row_column_field_options, dependent: :destroy, inverse_of: :question_row_column_field_option
  has_many :question_row_column_fields, through: :question_row_column_fields_question_row_column_field_options, dependent: :destroy
end
