# == Schema Information
#
# Table name: model_performances
#
#  id          :bigint           not null, primary key
#  ml_model_id :bigint
#  label       :string(255)
#  score       :float(24)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ModelPerformance < ApplicationRecord
  belongs_to :ml_model
end
