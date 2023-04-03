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
#  pos                   :integer          default(999999)
#
class AbstractScreeningsTagsUser < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :abstract_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(abstract_screening, user)
    astus = AbstractScreeningsTagsUser.where(abstract_screening:, user:).includes(:tag)
    astus.map do |astu|
      {
        id: astu.id,
        tag_id: astu.tag_id,
        name: astu.tag.name,
        pos: astu.pos,
        selected: false
      }
    end
  end
end
