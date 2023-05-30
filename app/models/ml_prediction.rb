# == Schema Information
#
# Table name: ml_predictions
#
#  id                   :bigint           not null, primary key
#  citations_project_id :integer          not null
#  ml_model_id          :bigint           not null
#  score                :float(24)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class MlPrediction < ApplicationRecord
  belongs_to :citations_project
  belongs_to :ml_model

  validates :score, presence: true
end
