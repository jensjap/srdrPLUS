# == Schema Information
#
# Table name: sd_result_items
#
#  id                 :bigint           not null, primary key
#  sd_key_question_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sd_meta_datum_id   :bigint
#  position           :integer          default(999999)
#

class SdResultItem < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_meta_datum, inverse_of: :sd_result_items, optional: true
  belongs_to :sd_key_question, inverse_of: :sd_result_items, optional: true

  has_many :sd_pairwise_meta_analytic_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_narrative_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_evidence_tables, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_network_meta_analysis_results, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_meta_regression_analysis_results, inverse_of: :sd_result_item, dependent: :destroy

  accepts_nested_attributes_for :sd_pairwise_meta_analytic_results, allow_destroy: true
  accepts_nested_attributes_for :sd_narrative_results, allow_destroy: true
  accepts_nested_attributes_for :sd_evidence_tables, allow_destroy: true
  accepts_nested_attributes_for :sd_network_meta_analysis_results, allow_destroy: true
  accepts_nested_attributes_for :sd_meta_regression_analysis_results, allow_destroy: true
end
