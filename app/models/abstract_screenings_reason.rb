# == Schema Information
#
# Table name: abstract_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  pos                   :integer          default(999999)
#
class AbstractScreeningsReason < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :abstract_screening
  belongs_to :reason
end
