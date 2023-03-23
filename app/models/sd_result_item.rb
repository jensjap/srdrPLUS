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
  include SharedOrderableMethods
  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create
  belongs_to :sd_meta_datum, inverse_of: :sd_result_items, optional: true
  belongs_to :sd_key_question, inverse_of: :sd_result_items, optional: true

  has_many :sd_pairwise_meta_analytic_results, -> { ordered }, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_narrative_results, -> { ordered }, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_evidence_tables, -> { ordered }, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_network_meta_analysis_results, -> { ordered }, inverse_of: :sd_result_item, dependent: :destroy
  has_many :sd_meta_regression_analysis_results, -> { ordered }, inverse_of: :sd_result_item, dependent: :destroy

  has_one :ordering, as: :orderable, dependent: :destroy

  accepts_nested_attributes_for :sd_pairwise_meta_analytic_results, allow_destroy: true
  accepts_nested_attributes_for :sd_narrative_results, allow_destroy: true
  accepts_nested_attributes_for :sd_evidence_tables, allow_destroy: true
  accepts_nested_attributes_for :sd_network_meta_analysis_results, allow_destroy: true
  accepts_nested_attributes_for :sd_meta_regression_analysis_results, allow_destroy: true
end
