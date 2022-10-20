# == Schema Information
#
# Table name: abstract_screenings_tags_users
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint
#  tag_id                :bigint
#  user_id               :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningsTagsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(abstract_screening, user)
    astus = AbstractScreeningsTagsUser.where(abstract_screening:, user:).includes(:tag)
    astus.each_with_object({}) do |astu, hash|
      hash[astu.tag.name] = false
      hash
    end
  end
end
