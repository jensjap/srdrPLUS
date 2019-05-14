# == Schema Information
#
# Table name: sd_key_questions_projects
#
#  id                       :integer          not null, primary key
#  sd_key_question_id       :integer
#  key_questions_project_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class SdKeyQuestionsProject < ApplicationRecord
  belongs_to :sd_key_question, inverse_of: :sd_key_questions_projects
  has_one :sd_meta_datum, through: :sd_key_question

  belongs_to :key_questions_project, inverse_of: :sd_key_questions_projects
  has_one :key_question, through: :key_questions_project
end
