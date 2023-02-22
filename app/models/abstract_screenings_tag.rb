# == Schema Information
#
# Table name: abstract_screenings_tags
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  tag_id                :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  pos                   :integer          default(999999)
#
class AbstractScreeningsTag < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :abstract_screening
  belongs_to :tag
end
