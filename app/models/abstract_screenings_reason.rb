# == Schema Information
#
# Table name: abstract_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningsReason < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :reason
end
