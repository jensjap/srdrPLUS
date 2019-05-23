class NetworkMetaAnalysisResult < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :network_meta_analysis_results
end
