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

        # For text, checkbox, dropdown, radio type questions we just need 1 row.
        self.question_row_columns.create

      elsif %w(Matrix\ Text Matrix\ Checkbox Matrix\ Dropdown Matrix\ Radio).include? self.question_type.name

        # For matrix type questions, the number of columns to create depends on
        # how many columns this matrix/the other rows have.
        create_appropriate_number_of_question_row_columns

      else

        raise 'Unknown QuestionType'

      end
    end

    def create_appropriate_number_of_question_row_columns
      # Need to reload self.question here because it is being cached and its CollectionProxy
      # doesn't have the newly created question_row yet.
      self.question.reload if self.question.question_rows.blank?

      if self.question.question_rows.first.question_row_columns.count == 0

        # If this is the first/only row in the matrix then we default to creating
        # (arbitrarily) 3 columns.
        self.question_row_columns.create
        self.question_row_columns.create
        self.question_row_columns.create

      else

        # Otherwise, create the same number of columns as other rows have.
        self.question.question_rows.first.question_row_columns.count.times do |c|
          self.question_row_columns.create
        end

      end

    end
end
