# == Schema Information
#
# Table name: abstract_screenings_reasons_users
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint
#  reason_id             :bigint
#  user_id               :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position              :integer
#
class AbstractScreeningsReasonsUser < ApplicationRecord
  default_scope { order(:position) }

  before_create :put_last

  belongs_to :abstract_screening
  belongs_to :reason
  belongs_to :user

  def self.custom_reasons_object(abstract_screening, user)
    asrus = AbstractScreeningsReasonsUser.where(abstract_screening:, user:).order(:position).includes(:reason)
    asrus.map do |asru|
      {
        id: asru.id,
        reason_id: asru.reason_id,
        name: asru.reason.name,
        position: asru.position,
        selected: false
      }
    end
  end

  private

  def put_last
    max_position = AbstractScreeningsReasonsUser.where(abstract_screening:, user:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
