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

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row

  accepts_nested_attributes_for :question_row_columns

  delegate :question_type, to: :question

  amoeba do
    enable
    clone [:question_row_columns]
  end
end
