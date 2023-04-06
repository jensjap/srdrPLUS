# == Schema Information
#
# Table name: sd_outcomes
#
#  id                  :bigint           not null, primary key
#  name                :string(255)
#  sd_outcomeable_id   :bigint
#  sd_outcomeable_type :string(255)
#

class SdOutcome < ApplicationRecord
  SD_OUTCOMEABLE_TYPES = %w[SdEvidenceTable SdMetaRegressionAnalysisResult SdNarrativeResult
                            SdNetworkMetaAnalysisResult SdPairwiseMetaAnalyticResult].freeze

  belongs_to :sd_outcomeable, polymorphic: true

  delegate :project, to: :sd_outcomeable
end
