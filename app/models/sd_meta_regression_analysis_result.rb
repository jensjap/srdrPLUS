# == Schema Information
#
# Table name: sd_meta_regression_analysis_results
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  sd_result_item_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdMetaRegressionAnalysisResult < ApplicationRecord
  include SharedOrderableMethods
  include SharedSdOutcomeableMethods

  before_validation -> { set_ordering_scoped_by(:sd_result_item_id) }, on: :create

  belongs_to :sd_result_item, inverse_of: :sd_meta_regression_analysis_results

  has_one_attached :picture

  has_many :sd_outcomes, as: :sd_outcomeable

  has_one :ordering, as: :orderable, dependent: :destroy
end
