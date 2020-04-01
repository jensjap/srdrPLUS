# == Schema Information
#
# Table name: sd_narrative_results
#
#  id                 :bigint(8)        not null, primary key
#  narrative_results_by_population               :text(65535)
#  narrative_results_by_intervention               :text(65535)
#  narrative_results  :text(65535)
#  sd_meta_datum_id   :integer
#  sd_key_question_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class SdNarrativeResult < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :comparison_outcome_population_subgroups, optional: true
  belongs_to :sd_key_question, inverse_of: :comparison_outcome_population_subgroups, optional: true

  has_many :sd_outcomes, as: :sd_outcomeable
end
