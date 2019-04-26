class QualityDimensionQuestion < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :quality_dimension_section, inverse_of: :quality_dimension_questions

  has_many :quality_dimension_questions_quality_dimension_options, inverse_of: :quality_dimension_question, dependent: :destroy
  has_many :quality_dimension_options, through: :quality_dimension_questions_quality_dimension_options
end
