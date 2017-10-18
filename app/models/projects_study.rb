class ProjectsStudy < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :project
  belongs_to :study

  has_many :extractions, dependent: :destroy, inverse_of: :projects_study
end
