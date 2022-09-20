class SfQuestion < ApplicationRecord
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
