class ComparisonOutcomeInterventionSubgroup < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :comparison_outcome_intervention_subgroups
  belongs_to :sd_key_question, inverse_of: :comparison_outcome_intervention_subgroups
end
