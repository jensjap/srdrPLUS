class QualityDimensionQuestionsQualityDimensionOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :quality_dimension_question
  belongs_to :quality_dimension_option
end
