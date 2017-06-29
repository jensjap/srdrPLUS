class QuestionRowColumnFieldOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  before_save :default_values

  belongs_to :question_row_column_field, inverse_of: :question_row_column_field_options

  private

    def default_values
      self.key = 'option' if self.key.nil?
    end
end
