class QualityDimensionSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :quality_dimension_questions, inverse_of: :quality_dimension_section
end
