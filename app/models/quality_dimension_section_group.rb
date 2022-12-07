# == Schema Information
#
# Table name: quality_dimension_section_groups
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QualityDimensionSectionGroup < ApplicationRecord
  has_many :quality_dimension_sections, inverse_of: :quality_dimension_section_group
end
