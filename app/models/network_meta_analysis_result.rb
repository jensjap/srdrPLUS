# == Schema Information
#
# Table name: network_meta_analysis_results
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  sd_result_item_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  p_type           :string(255)
#

class NetworkMetaAnalysisResult < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_result_item, inverse_of: :network_meta_analysis_results

  has_many :sd_outcomes, as: :sd_outcomeable
end
