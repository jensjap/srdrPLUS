# == Schema Information
#
# Table name: question_row_column_options
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string(255)
#  field_type  :string(255)
#  label       :string(255)
#

class QuestionRowColumnOption < ApplicationRecord
  ANSWER_CHOICE   = 'answer_choice'.freeze
  MIN_LENGTH      = 'min_length'.freeze
  MAX_LENGTH      = 'max_length'.freeze
  ADDITIONAL_CHAR = 'additional_char'.freeze
  MIN_VALUE       = 'min_value'.freeze
  MAX_VALUE       = 'max_value'.freeze
  COEFFICIENT     = 'coefficient'.freeze
  EXPONENT        = 'exponent'.freeze

  ANSWER_CHOICE_QRCO = QuestionRowColumnOption.find_by(name: 'answer_choice')

  has_many :question_row_columns_question_row_column_options, dependent: :destroy,
                                                              inverse_of: :question_row_column_option
  has_many :question_row_columns, through: :question_row_columns_question_row_column_options, dependent: :destroy
end
