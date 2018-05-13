class Label < ApplicationRecord
  scope :last_updated, -> ( user, project, offset, count ) { joins(:citations_project)
                                                .where(citations_projects: { project_id: project.id })
                                                .includes(:citation)
                                                .where(user: user)
                                                .order(updated_at: :desc)
                                                .distinct
                                                .offset(offset)
                                                .limit(count) }  
  belongs_to :citations_project
  belongs_to :user

  has_many :notes, as: :notable
  has_many :tags, as: :taggable

  has_one :citation, through: :citations_project
  has_one :project, through: :citations_project

  validates :value, presence: true
end
