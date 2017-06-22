class QuestionRow < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_columns

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, inverse_of: :question_row

  delegate :question_type, to: :question

  private

    def create_default_question_row_columns
      case self.question_type
      when QuestionType.find(1)  # Text
        self.question_row_columns.create
      when QuestionType.find(2)  # Checkbox
        self.question_row_columns.create
      when QuestionType.find(3)  # Dropdown
        self.question_row_columns.create
      when QuestionType.find(4)  # Radio
        self.question_row_columns.create
      when QuestionType.find(5)  # Matrix Checkbox
        self.question_row_columns.create
        self.question_row_columns.create
        self.question_row_columns.create
      when QuestionType.find(6)  # Matrix Dropdown
        self.question_row_columns.create
        self.question_row_columns.create
        self.question_row_columns.create
      when QuestionType.find(7)  # Matrix Radio
        self.question_row_columns.create
        self.question_row_columns.create
        self.question_row_columns.create
      else
        raise 'Unknown QuestionType'
      end
    end
end
