# == Schema Information
#
# Table name: key_question_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class KeyQuestionType < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_key_questions_key_question_types, inverse_of: :key_question_type
  has_many :sd_key_questions, through: :sd_key_questions_key_question_types
end
