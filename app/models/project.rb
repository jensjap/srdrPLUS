class Project < ApplicationRecord
  include SharedPublishableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8

  # Ensure that key question position is correct.
  after_update do |project|
    KeyQuestionsProject.where(project: project).order(position: :asc).each_with_index do |key_questions_project, index|
      key_questions_project.position = index + 1
      key_questions_project.save
    end
  end

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy
  has_many :publishings, as: :publishable, dependent: :destroy
  has_many :approvals, through: :publishings, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :key_questions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :key_questions_projects, reject_if: :all_blank, allow_destroy: true
end
