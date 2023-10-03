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
#  pos                   :integer          default(999999)
#
class FulltextScreeningsReasonsUser < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :fulltext_screening
  belongs_to :reason
  belongs_to :user
end
