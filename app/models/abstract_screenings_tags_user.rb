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
#  position              :integer
#
class AbstractScreeningsTagsUser < ApplicationRecord
  before_create :put_last

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

  private

  def put_last
    max_position = AbstractScreeningsTagsUser.where(abstract_screening:, user:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
