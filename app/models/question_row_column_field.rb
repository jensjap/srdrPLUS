class QuestionRowColumnField < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_row_column_field_options

  belongs_to :question_row_column, inverse_of: :question_row_column_field
  belongs_to :question_row_column_field_type, inverse_of: :question_row_column_fields

  has_many :question_row_column_field_options, dependent: :destroy, inverse_of: :question_row_column_field

  accepts_nested_attributes_for :question_row_column_field_options

  delegate :question_type, to: :question_row_column

  private

    def create_default_question_row_column_field_options
      if %w(Text Matrix\ Text).include? self.question_type.name
      #if [1, 5].include? self.question_type.id
        self.question_row_column_field_type = QuestionRowColumnFieldType.find_by(name: 'alphanumeric')
        self.question_row_column_field_options.create(key: 'min_length', value: 0,   value_type: 'decimal')
        self.question_row_column_field_options.create(key: 'max_length', value: 255, value_type: 'decimal')
        self.save
      elsif %w(Checkbox Dropdown Radio Matrix\ Checkbox Matrix\ Dropdown Matrix\ Radio).include? self.question_type.name
      #elsif [2, 3, 4, 6, 7, 8].include? self.question_type.id
        self.question_row_column_field_type = QuestionRowColumnFieldType.find_by(name: 'option')
        self.question_row_column_field_options.create(key: 'option', value: 'option a')
        self.question_row_column_field_options.create(key: 'option', value: 'option b')
        self.question_row_column_field_options.create(key: 'option', value: 'option c')
        self.question_row_column_field_options.create(key: 'option', value: 'option d')
        self.save
      end
    end
end
