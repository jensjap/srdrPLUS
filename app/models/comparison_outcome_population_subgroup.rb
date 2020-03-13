# == Schema Information
#
# Table name: comparison_outcome_population_subgroups
#
#  id                 :bigint(8)        not null, primary key
#  name               :text(65535)
#  narrative_results  :text(65535)
#  sd_meta_datum_id   :integer
#  sd_key_question_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ComparisonOutcomePopulationSubgroup < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :comparison_outcome_population_subgroups, optional: true
  belongs_to :sd_key_question, inverse_of: :comparison_outcome_population_subgroups, optional: true
end
