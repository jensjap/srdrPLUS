# == Schema Information
#
# Table name: sd_meta_regression_analysis_results
#
#  id                :bigint           not null, primary key
#  name              :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sd_result_item_id :bigint
#  position          :integer          default(999999)
#

class SdMetaRegressionAnalysisResult < ApplicationRecord
  default_scope { order(:pos, :id) }

  include SharedSdOutcomeableMethods

  belongs_to :sd_result_item, inverse_of: :sd_meta_regression_analysis_results
  has_many :sd_outcomes, as: :sd_outcomeable
  has_many :sd_meta_data_figures, as: :sd_figurable

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true
end
