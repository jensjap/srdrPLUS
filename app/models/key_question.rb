class KeyQuestion < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :key_question
  has_many :extraction_forms, through: :key_questions_projects, dependent: :destroy
  has_many :projects, through: :key_questions_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def as_a_resource(project)
    self.key_questions_projects.find_by(project: project)
  end
end
