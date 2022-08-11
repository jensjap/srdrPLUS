# == Schema Information
#
# Table name: projects_studies
#
#  id         :integer          not null, primary key
#  project_id :integer
#  study_id   :integer
#  deleted_at :datetime
#  active     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectsStudy < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  belongs_to :project, inverse_of: :projects_studies # , touch: true
  belongs_to :study,   inverse_of: :projects_studies

  # has_many :extractions, dependent: :destroy, inverse_of: :projects_study
end
