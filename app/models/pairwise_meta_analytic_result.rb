class PairwiseMetaAnalyticResult < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :pairwise_meta_analytic_results
end
