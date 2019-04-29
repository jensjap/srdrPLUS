class QualityDimensionSectionGroup < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :quality_dimension_sections, inverse_of: :quality_dimension_section_group
end
