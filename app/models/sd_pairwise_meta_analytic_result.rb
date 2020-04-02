# == Schema Information
#
# Table name: sd_pairwise_meta_analytic_results
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  p_type           :string(255)
#  sd_result_item_id :integer
#

class SdPairwiseMetaAnalyticResult < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_result_item, inverse_of: :sd_pairwise_meta_analytic_results

  has_many :sd_outcomes, as: :sd_outcomeable
end
