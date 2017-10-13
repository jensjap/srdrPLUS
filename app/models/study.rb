class Study < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :projects_studies, dependent: :destroy, inverse_of: :study
  has_many :projects, through: :projects_studies, dependent: :destroy
end
