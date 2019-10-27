# == Schema Information
#
# Table name: sd_meta_regression_analysis_results
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdMetaRegressionAnalysisResult < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_meta_regression_analysis_results
end
