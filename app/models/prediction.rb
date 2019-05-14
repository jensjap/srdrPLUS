# == Schema Information
#
# Table name: predictions
#
#  id                    :integer          not null, primary key
#  citations_project_id  :integer
#  value                 :integer
#  num_yes_votes         :integer
#  predicted_probability :float(24)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Prediction < ApplicationRecord
  belongs_to :citations_project
end
