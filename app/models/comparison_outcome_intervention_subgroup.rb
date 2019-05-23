class ComparisonOutcomeInterventionSubgroup < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :comparison_outcome_intervention_subgroups
end
