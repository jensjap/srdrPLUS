# == Schema Information
#
# Table name: sd_key_questions_key_question_types
#
#  id                   :bigint(8)        not null, primary key
#  sd_key_question_id   :bigint(8)
#  key_question_type_id :bigint(8)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class SdKeyQuestionsKeyQuestionType < ApplicationRecord
  include SharedProcessTokenMethods

  belongs_to :sd_key_question, inverse_of: :sd_key_questions_key_question_types
  belongs_to :key_question_type, inverse_of: :sd_key_questions_key_question_types
end
