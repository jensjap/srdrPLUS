# == Schema Information
#
# Table name: question_row_column_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QuestionRowColumnType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row_column_type
end
