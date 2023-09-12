# == Schema Information
#
# Table name: training_data_infos
#
#  id          :bigint           not null, primary key
#  category    :string(255)
#  count       :integer
#  ml_model_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TrainingDataInfo < ApplicationRecord
  belongs_to :ml_model
end
