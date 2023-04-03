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
#  pos                   :integer          default(999999)
#
class FulltextScreeningsTagsUser < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :fulltext_screening
  belongs_to :tag
  belongs_to :user

  def self.custom_tags_object(fulltext_screening, user)
    fstus = FulltextScreeningsTagsUser.where(fulltext_screening:, user:).includes(:tag)
    fstus.map do |fstu|
      {
        id: fstu.id,
        tag_id: fstu.tag_id,
        name: fstu.tag.name,
        pos: fstu.pos,
        selected: false
      }
    end
  end
end
