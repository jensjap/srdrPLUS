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
  belongs_to :extraction
  belongs_to :key_questions_project
end
