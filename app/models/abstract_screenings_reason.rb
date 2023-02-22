# == Schema Information
#
# Table name: abstract_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position              :integer
#
class AbstractScreeningsReason < ApplicationRecord
  default_scope { order(:position) }

  belongs_to :abstract_screening
  belongs_to :reason

  before_create :put_last

  private

  def put_last
    max_position = AbstractScreeningsReason.where(abstract_screening:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
