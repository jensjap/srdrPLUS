# == Schema Information
#
# Table name: sf_questions
#
#  id                :bigint           not null, primary key
#  screening_form_id :bigint
#  name              :string(255)
#  description       :text(65535)
#  position          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class SfQuestion < ApplicationRecord
  default_scope { order(:position) }

  belongs_to :screening_form
  has_many :sf_rows, dependent: :destroy, inverse_of: :sf_question
  has_many :sf_columns, dependent: :destroy, inverse_of: :sf_question

  before_create :put_last

  private

  def put_last
    max_position = SfQuestion.where(screening_form_id:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
