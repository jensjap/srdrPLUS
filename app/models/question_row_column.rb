class QuestionRowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_column_fields

  belongs_to :question_row, inverse_of: :question_row_columns

  has_one :question_row_column_field, inverse_of: :question_row_column

  delegate :question_type, to: :question_row

  private

    def create_default_question_row_column_fields
      case self.question_type
      when QuestionType.find(1)  # Text
        self.create_question_row_column_field
      when QuestionType.find(2)  # Checkbox
        self.create_question_row_column_field
      when QuestionType.find(3)  # Dropdown
        self.create_question_row_column_field
      when QuestionType.find(4)  # Radio
        self.create_question_row_column_field
      when QuestionType.find(5)  # Matrix Checkbox
        self.create_question_row_column_field
      when QuestionType.find(6)  # Matrix Dropdown
        self.create_question_row_column_field
      when QuestionType.find(7)  # Matrix Radio
        self.create_question_row_column_field
      else
        raise 'Unknown QuestionType'
      end
    end
end
