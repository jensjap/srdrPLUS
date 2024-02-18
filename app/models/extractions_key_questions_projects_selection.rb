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
  scope :not_disqualified,
        lambda {
          joins(extraction: :citations_project)
            .where
            .not(citations_project: { screening_status: CitationsProject::REJECTED })
        }

  belongs_to :extraction
  belongs_to :key_questions_project
end
