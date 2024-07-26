# == Schema Information
#
# Table name: extractions_key_questions_projects_selections
#
#  id                       :bigint           not null, primary key
#  extraction_id            :bigint
#  key_questions_project_id :bigint
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class ExtractionsKeyQuestionsProjectsSelection < ApplicationRecord
  attr_accessor :is_amoeba_copy

  before_commit :correct_kqs_association

  amoeba do
    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  belongs_to :extraction
  belongs_to :key_questions_project

  private

  def correct_kqs_association
    return unless is_amoeba_copy

    key_question_id = key_questions_project.key_question_id
    key_questions_project_id = extraction.project.key_questions_projects.find_by(key_question_id:).id
    update(key_questions_project_id:)
  end
end
