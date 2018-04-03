class QualityDimensionOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :quality_dimension_questions_quality_dimension_options, inverse_of: :quality_dimension_option
  has_many :quality_dimension_questions, through: :quality_dimension_questions_quality_dimension_options
end
