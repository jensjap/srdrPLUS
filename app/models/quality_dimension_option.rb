# == Schema Information
#
# Table name: quality_dimension_options
#
#  id         :integer          not null, primary key
#  name       :text(16777215)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QualityDimensionOption < ApplicationRecord
  acts_as_paranoid

  has_many :dependencies, as: :prerequisitable, dependent: :destroy
  has_many :quality_dimension_questions_quality_dimension_options, inverse_of: :quality_dimension_option
  has_many :quality_dimension_questions, through: :quality_dimension_questions_quality_dimension_options
end
