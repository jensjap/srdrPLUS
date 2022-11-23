# == Schema Information
#
# Table name: fulltext_screenings_tags_users
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint
#  tag_id                :bigint
#  user_id               :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FulltextScreeningsTagsUser < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(fulltext_screening, user)
    fstus = FulltextScreeningsTagsUser.where(fulltext_screening:, user:).includes(:tag)
    fstus.each_with_object({}) do |fstu, hash|
      hash[fstu.tag.name] = false
      hash
    end
  end
end
