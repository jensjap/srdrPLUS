# == Schema Information
#
# Table name: abstract_screenings_tags
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  tag_id                :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  position              :integer
#
class AbstractScreeningsTag < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :tag
end
