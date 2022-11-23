# == Schema Information
#
# Table name: fulltext_screenings_reasons
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  reason_id             :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FulltextScreeningsReason < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :reason
end
