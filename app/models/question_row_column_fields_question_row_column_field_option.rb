class QuestionRowColumnFieldsQuestionRowColumnFieldOption < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  after_create :set_default_values

  belongs_to :question_row_column_field, inverse_of: :question_row_column_fields_question_row_column_field_options
  belongs_to :question_row_column_field_option, inverse_of: :question_row_column_fields_question_row_column_field_options

  delegate :question, to: :question_row_column_field
  delegate :question_row_column_field_type, to: :question_row_column_field

  private

  def set_default_values
    case self.question_row_column_field_option.name
    when 'answer_choice'
      self.value_type = 'string'
    when 'min_length'
      self.value      = 0
      self.value_type = 'integer'
    when 'max_length'
      self.value      = 255
      self.value_type = 'integer'
    when 'min_value'
      self.value      = 0
      self.value_type = 'integer'
    when 'max_value'
      self.value      = 255
      self.value_type = 'integer'
    when 'coefficient'
      self.value      = 5
      self.value_type = 'integer'
    when 'exponent'
      self.value      = 0
      self.value_type = 'integer'
    else
      raise 'Unknown QuestionRowColumnFieldOption'
    end

    self.save
  end
end
