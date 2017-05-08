class KeyQuestion < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :extraction_form, inverse_of: :key_questions, optional: true

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :key_question
  has_many :projects, through: :key_questions_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def as_a_resource(project)
    self.key_questions_projects.find_by(project: project)
  end
end
