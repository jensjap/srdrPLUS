# == Schema Information
#
# Table name: key_questions_projects_questions
#
#  id                       :integer          not null, primary key
#  key_questions_project_id :integer
#  question_id              :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class KeyQuestionsProjectsQuestion < ApplicationRecord
  attr_accessor :is_amoeba_copy

  amoeba do
    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :key_questions_project, inverse_of: :key_questions_projects_questions
  belongs_to :question,              inverse_of: :key_questions_projects_questions

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    correct_key_questions_project_association
  end

  def correct_key_questions_project_association
    update(key_questions_project: KeyQuestionsProject.find_by(
      key_question: key_questions_project.key_question,
      project: question.project
    ))
  end
end
