# == Schema Information
#
# Table name: fulltext_screenings_tags
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  tag_id                :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  pos                   :integer          default(999999)
#
class FulltextScreeningsTag < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :fulltext_screening
  belongs_to :tag
end
