class Label < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  scope :last_updated, -> ( projects_users_role, project, offset, count ) { joins(:citations_project)
                                                .where(citations_projects: { project_id: project.id })
                                                .includes(:citation)
                                                .where(projects_users_role: projects_users_role)
                                                .order(updated_at: :desc)
                                                .distinct
                                                .offset(offset)
                                                .limit(count) }  
  belongs_to :citations_project
  belongs_to :projects_users_role

  has_many :notes, as: :notable
  has_many :tags, as: :taggable

  has_one :citation, through: :citations_project
  has_one :project, through: :citations_project
  has_one :projects_user, through: :projects_users_role
  has_one :user, through: :projects_users

  has_many :labels_reasons, dependent: :destroy
  has_many :reasons, through: :labels_reasons

  validates :value, presence: true
end
