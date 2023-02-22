# == Schema Information
#
# Table name: sd_narrative_results
#
#  id                                :bigint           not null, primary key
#  narrative_results                 :text(65535)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  narrative_results_by_population   :text(65535)
#  narrative_results_by_intervention :text(65535)
#  sd_result_item_id                 :bigint
#  pos                               :integer          default(999999)
#

class SdNarrativeResult < ApplicationRecord
  default_scope { order(:pos, :id) }

  include SharedSdOutcomeableMethods

  belongs_to :sd_result_item, inverse_of: :sd_narrative_results

  has_many :sd_outcomes, as: :sd_outcomeable
end
