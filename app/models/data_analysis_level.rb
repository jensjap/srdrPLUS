# == Schema Information
#
# Table name: data_analysis_levels
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DataAnalysisLevel < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_meta_data, inverse_of: :data_analysis_level
end

