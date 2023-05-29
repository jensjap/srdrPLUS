class MlModel < ApplicationRecord
  has_many :ml_models_projects
  has_many :projects, through: :ml_models_projects
  has_many :model_performances

  validates :timestamp, presence: true
end
