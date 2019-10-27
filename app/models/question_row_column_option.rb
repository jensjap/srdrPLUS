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
  acts_as_paranoid
  has_paper_trail

  has_many :question_row_columns_question_row_column_options, dependent: :destroy, inverse_of: :question_row_column_option
  has_many :question_row_columns, through: :question_row_columns_question_row_column_options, dependent: :destroy
end
