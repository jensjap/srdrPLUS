class QuestionRowColumnField < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_column_field_options

  belongs_to :question_row_column, inverse_of: :question_row_column_field

  has_many :question_row_column_field_options, inverse_of: :question_row_column_field

  delegate :question_type, to: :question_row_column

  private

    def create_default_question_row_column_field_options
      case self.question_type
      when QuestionType.find(1)  # Text
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
      when QuestionType.find(2)  # Checkbox
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      when QuestionType.find(3)  # Dropdown
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      when QuestionType.find(4)  # Radio
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      when QuestionType.find(5)  # Matrix Checkbox
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      when QuestionType.find(6)  # Matrix Dropdown
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      when QuestionType.find(7)  # Matrix Radio
        self.question_row_column_field_options.create(key: 'min_length', value: 0)
        self.question_row_column_field_options.create(key: 'max_length', value: 255)
        self.question_row_column_field_options.create(key: 'field_type', value: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
      else
        raise 'Unknown QuestionType'
      end
    end
end
