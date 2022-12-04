# == Schema Information
#
# Table name: quality_dimension_questions_quality_dimension_options
#
#  id                            :integer          not null, primary key
#  quality_dimension_question_id :integer
#  quality_dimension_option_id   :integer
#  deleted_at                    :datetime
#  active                        :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class QualityDimensionQuestionsQualityDimensionOption < ApplicationRecord
  belongs_to :quality_dimension_question
  belongs_to :quality_dimension_option
end
