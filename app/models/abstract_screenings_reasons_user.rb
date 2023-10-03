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
#  pos                   :integer          default(999999)
#
class AbstractScreeningsReasonsUser < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :abstract_screening
  belongs_to :reason
  belongs_to :user
end
