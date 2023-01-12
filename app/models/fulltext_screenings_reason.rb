# == Schema Information
#
# Table name: fulltext_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position :integer
#
class FulltextScreeningsReason < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :reason

  before_create :put_last

  private

  def put_last
    max_position = FulltextScreeningsReason.where(fulltext_screening:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
