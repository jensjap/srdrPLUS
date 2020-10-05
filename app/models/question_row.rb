# == Schema Information
#
# Table name: question_rows
#
#  id          :integer          not null, primary key
#  question_id :integer
#  name        :string(255)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class QuestionRow < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_columns

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row

  accepts_nested_attributes_for :question_row_columns

  delegate :question_type, to: :question

  amoeba do
    enable
    clone [:question_row_columns]
  end

  private

    def create_default_question_row_columns
      if self.question.question_rows.first.question_row_columns.length == 0
        # If this is the first/only row in the matrix then we default to creating
        # (arbitrarily) 1 column.
        self.question_row_columns.create(
          question_row_column_type: QuestionRowColumnType.find_by(name: 'text')
        )
      else
        # Otherwise, create the same number of columns as first row has.
        self.question.question_rows.first.question_row_columns.count.times do |c|
          self.question_row_columns.create(
            question_row_column_type: QuestionRowColumnType.find_by(name: 'text')
          )
        end
      end

      #!!!!! Do we need this still????
      # Newly created question_row_columns do not have their name field set.
      # This triggers after_save :ensure_matrix_column_headers callback in
      # question model to set the name field.
      self.question.save
    end
end
