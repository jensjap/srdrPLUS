# == Schema Information
#
# Table name: fulltext_screenings_reasons_users
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint
#  reason_id             :bigint
#  user_id               :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position              :integer
#
class FulltextScreeningsReasonsUser < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :fulltext_screening
  belongs_to :reason
  belongs_to :user

  def self.custom_reasons_object(fulltext_screening, user)
    fsrus = FulltextScreeningsReasonsUser.where(fulltext_screening:, user:).order(:position).includes(:reason)
    fsrus.map do |fsru|
      {
        id: fsru.id,
        reason_id: fsru.reason_id,
        name: fsru.reason.name,
        position: fsru.position,
        selected: false
      }
    end
  end
end
