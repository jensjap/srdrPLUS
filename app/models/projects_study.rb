class ProjectsStudy < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :project, inverse_of: :projects_studies
  belongs_to :study,   inverse_of: :projects_studies

  #has_many :extractions, dependent: :destroy, inverse_of: :projects_study
end
