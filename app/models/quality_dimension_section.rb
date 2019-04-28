class QualityDimensionSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :quality_dimension_section_group, inverse_of: :quality_dimension_sections
  has_many :quality_dimension_questions, inverse_of: :quality_dimension_section
end
