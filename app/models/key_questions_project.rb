# == Schema Information
#
# Table name: key_questions_projects
#
#  id                                   :integer          not null, primary key
#  key_question_id                      :integer
#  project_id                           :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  pos                                  :integer          default(999999)
#

class KeyQuestionsProject < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :key_question,                      inverse_of: :key_questions_projects
  belongs_to :project,                           inverse_of: :key_questions_projects # , touch: true

  has_many :key_questions_projects_questions, dependent: :destroy, inverse_of: :key_questions_project
  has_many :questions, through: :key_questions_projects_questions

  has_many :sd_key_questions_projects, inverse_of: :key_questions_project
  has_many :sd_key_questions, through: :sd_key_questions_projects

  has_many :extractions_key_questions_projects_selections, -> { not_disqualified }, dependent: :destroy

  accepts_nested_attributes_for :key_question, reject_if: :key_question_name_exists?

  def abs_pos
    project.key_questions_projects.index(self) + 1
  end

  def kq_name
    "#{key_question.name}"
  end

  private

  def key_question_name_exists?(attributes)
    return true if attributes[:name].blank?

    begin
      self.key_question = KeyQuestion.where(name: attributes[:name]).first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
