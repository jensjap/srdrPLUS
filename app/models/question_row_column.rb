class QuestionRowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_column_field

  belongs_to :question_row, inverse_of: :question_row_columns

  has_one :question_row_column_field, dependent: :destroy, inverse_of: :question_row_column
  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  accepts_nested_attributes_for :question_row_column_field

  delegate :question, to: :question_row
  delegate :question_type, to: :question_row
  delegate :question_row_column_field_type, to: :question_row_column_field

  private

    def create_default_question_row_column_field
      self.create_question_row_column_field
    end
end
