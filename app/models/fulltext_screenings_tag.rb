# == Schema Information
#
# Table name: fulltext_screenings_tags
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  tag_id                :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position              :integer
#
class FulltextScreeningsTag < ApplicationRecord
  default_scope { order(:position) }

  belongs_to :fulltext_screening
  belongs_to :tag
end
