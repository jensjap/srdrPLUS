# == Schema Information
#
# Table name: key_questions_projects_questions
#
#  id                       :integer          not null, primary key
#  key_questions_project_id :integer
#  question_id              :integer
#  deleted_at               :datetime
#  active                   :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class KeyQuestionsProjectsQuestion < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  belongs_to :key_questions_project, inverse_of: :key_questions_projects_questions
  belongs_to :question,              inverse_of: :key_questions_projects_questions
end
