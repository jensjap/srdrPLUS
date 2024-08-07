# == Schema Information
#
# Table name: quality_dimension_options
#
#  id         :integer          not null, primary key
#  name       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QualityDimensionOption < ApplicationRecord
  has_many :dependencies, as: :prerequisitable, dependent: :destroy
  has_many :quality_dimension_questions_quality_dimension_options, inverse_of: :quality_dimension_option
  has_many :quality_dimension_questions, through: :quality_dimension_questions_quality_dimension_options
end
