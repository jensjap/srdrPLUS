class Project < ApplicationRecord
  include SharedPublishableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8

  after_create :create_default_extraction_form

  has_many :extractions, dependent: :destroy, inverse_of: :project

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :project
  has_many :extraction_forms, through: :extraction_forms_projects, dependent: :destroy

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  has_many :projects_studies, dependent: :destroy, inverse_of: :project
  has_many :studies, through: :projects_studies, dependent: :destroy

  has_many :projects_users, dependent: :destroy, inverse_of: :project
  has_many :users, through: :projects_users, dependent: :destroy

  has_many :publishings, as: :publishable, dependent: :destroy

  has_many :citations_projects, dependent: :destroy
  has_many :citations, through: :citations_projects
  has_many :tasks, dependent: :destroy
  has_many :assignments, through: :tasks, dependent: :destroy

  validates :name, presence: true

  #accepts_nested_attributes_for :extraction_forms_projects, reject_if: :all_blank, allow_destroy: true
  #accepts_nested_attributes_for :key_questions_projects, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :citations
  accepts_nested_attributes_for :citations_projects, allow_destroy: true
  accepts_nested_attributes_for :tasks, allow_destroy: true
  accepts_nested_attributes_for :assignments, allow_destroy: true

  def duplicate_key_question?
    self.key_questions.having('count(*) > 1').group('name').length.nonzero?
  end

  def duplicate_extraction_form?
    self.extraction_forms.having('count(*) > 1').group('name').length.nonzero?
  end

  def key_questions_projects_array_for_select
    self.key_questions_projects.map { |kqp| [kqp.key_question.name, kqp.id] }
  end

  private

    def create_default_extraction_form
      self.extraction_forms_projects.create!(extraction_forms_project_type: ExtractionFormsProjectType.first, extraction_form: ExtractionForm.first)
    end
end
