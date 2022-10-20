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
#
class FulltextScreeningsReasonsUser < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :reason
  belongs_to :user

  def self.custom_reasons_object(fulltext_screening, user)
    fsrus = FulltextScreeningsReasonsUser.where(fulltext_screening:, user:).includes(:reason)
    fsrus.each_with_object({}) do |fsru, hash|
      hash[fsru.reason.name] = false
      hash
    end
  end
end
