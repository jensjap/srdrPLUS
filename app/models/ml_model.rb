# == Schema Information
#
# Table name: ml_models
#
#  id         :bigint           not null, primary key
#  timestamp  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MlModel < ApplicationRecord
  has_many :ml_models_projects
  has_many :projects, through: :ml_models_projects
  has_many :model_performances

  validates :timestamp, presence: true
end
