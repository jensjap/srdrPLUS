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

  amoeba do
    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  before_commit :correct_parent_associations

  belongs_to :extraction
  belongs_to :key_questions_project

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    correct_kqs_association
  end

  def correct_kqs_association
    update(key_questions_project: extraction.project.key_questions_projects.find_by(key_question: key_questions_project.key_question))
  end
end
