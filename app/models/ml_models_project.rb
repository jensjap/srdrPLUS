class MlModelsProject < ApplicationRecord
  belongs_to :ml_model
  belongs_to :project
end
