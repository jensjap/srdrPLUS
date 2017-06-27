class QuestionRow < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_columns

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row

  accepts_nested_attributes_for :question_row_columns

  delegate :question_type, to: :question

  private

    def create_default_question_row_columns
      if %w(Text Checkbox Dropdown Radio).include? self.question_type.name
      #if [1, 2, 3, 4].include? self.question_type.id
        self.question_row_columns.create
      elsif %w(Matrix\ Text Matrix\ Checkbox Matrix\ Dropdown Matrix\ Radio).include? self.question_type.name
      #elsif [5, 6, 7, 8].include? self.question_type.id
        self.question_row_columns.create
        self.question_row_columns.create
        self.question_row_columns.create
      else
        raise 'Unknown QuestionType'
      end
    end
end
