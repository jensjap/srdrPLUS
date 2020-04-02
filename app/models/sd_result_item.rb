class SdResultItem < ApplicationRecord
  belongs_to :sd_key_question, inverse_of: :sd_result_items, optional: true

  has_many :sd_pairwise_meta_analytic_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_narrative_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_evidence_tables, inverse_of: :sd_result_item, dependent: :destroy
  has_many :network_meta_analysis_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_meta_regression_analysis_results, inverse_of: :sd_result_item, dependent: :destroy

  accepts_nested_attributes_for :sd_pairwise_meta_analytic_results, allow_destroy: true
  accepts_nested_attributes_for :sd_narrative_results, allow_destroy: true
  accepts_nested_attributes_for :sd_evidence_tables, allow_destroy: true
  accepts_nested_attributes_for :network_meta_analysis_results, allow_destroy: true
  accepts_nested_attributes_for :sd_meta_regression_analysis_results, allow_destroy: true
end
