# == Schema Information
#
# Table name: sd_pairwise_meta_analytic_results
#
#  id                :bigint           not null, primary key
#  name              :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sd_result_item_id :bigint
#  pos               :integer          default(999999)
#

class SdPairwiseMetaAnalyticResult < ApplicationRecord
  default_scope { order(:pos, :id) }

  include SharedSdOutcomeableMethods

  belongs_to :sd_result_item, inverse_of: :sd_pairwise_meta_analytic_results
  has_many :sd_meta_data_figures, as: :sd_figurable
  has_many :sd_outcomes, as: :sd_outcomeable

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true
end
