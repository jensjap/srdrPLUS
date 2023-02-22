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
#  position              :integer
#
class FulltextScreeningsTagsUser < ApplicationRecord
  default_scope { order(:position) }

  before_create :put_last

  belongs_to :fulltext_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(fulltext_screening, user)
    fstus = FulltextScreeningsTagsUser.where(fulltext_screening:, user:).order(:position).includes(:tag)
    fstus.map do |fstu|
      {
        id: fstu.id,
        tag_id: fstu.tag_id,
        name: fstu.tag.name,
        position: fstu.position,
        selected: false
      }
    end
  end

  private

  def put_last
    max_position = FulltextScreeningsTagsUser.where(fulltext_screening:, user:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
