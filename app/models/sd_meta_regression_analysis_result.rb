class SdMetaRegressionAnalysisResult < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_meta_regression_analysis_results
end
