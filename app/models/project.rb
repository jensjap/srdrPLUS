class Project < ApplicationRecord
  include SharedPublishableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy
  has_many :publishings, as: :publishable, dependent: :destroy
  has_many :approvals, through: :publishings, dependent: :destroy

  validates :name, presence: true

  #accepts_nested_attributes_for :key_questions, reject_if: :all_blank
  accepts_nested_attributes_for :key_questions_projects, reject_if: :all_blank, allow_destroy: true
end
