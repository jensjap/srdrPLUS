class MlPrediction < ApplicationRecord
  belongs_to :citations_project
  belongs_to :ml_model

  validates :score, presence: true
end
