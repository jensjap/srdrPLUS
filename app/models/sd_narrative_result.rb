# == Schema Information
#
# Table name: sd_narrative_results
#
#  id                                :bigint           not null, primary key
#  narrative_results                 :text(16777215)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  narrative_results_by_population   :text(16777215)
#  narrative_results_by_intervention :text(16777215)
#  sd_result_item_id                 :bigint
#

class SdNarrativeResult < ApplicationRecord
  include SharedOrderableMethods
  include SharedSdOutcomeableMethods

  before_validation -> { set_ordering_scoped_by(:sd_result_item_id) }, on: :create

  belongs_to :sd_result_item, inverse_of: :sd_narrative_results

  has_many :sd_outcomes, as: :sd_outcomeable
  has_one :ordering, as: :orderable, dependent: :destroy
end
