# == Schema Information
#
# Table name: ml_models_projects
#
#  id          :bigint           not null, primary key
#  ml_model_id :bigint           not null
#  project_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class MlModelsProject < ApplicationRecord
  belongs_to :ml_model
  belongs_to :project
end
