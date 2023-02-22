# == Schema Information
#
# Table name: fulltext_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  pos                   :integer          default(999999)
#
class FulltextScreeningsReason < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :fulltext_screening
  belongs_to :reason
end
