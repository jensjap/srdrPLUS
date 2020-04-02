# == Schema Information
#
# Table name: sd_narrative_results
#
#  id                 :bigint(8)        not null, primary key
#  narrative_results_by_population               :text(65535)
#  narrative_results_by_intervention               :text(65535)
#  narrative_results  :text(65535)
#  sd_meta_datum_id   :integer
#  sd_result_item_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class SdNarrativeResult < ApplicationRecord
  include SharedSdOutcomeableMethods

  belongs_to :sd_result_item, inverse_of: :sd_narrative_results

  has_many :sd_outcomes, as: :sd_outcomeable
end
