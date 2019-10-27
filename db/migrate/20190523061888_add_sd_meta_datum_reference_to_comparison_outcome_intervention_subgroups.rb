class AddSdMetaDatumReferenceToComparisonOutcomeInterventionSubgroups < ActiveRecord::Migration[5.0]
  def change
    add_reference :comparison_outcome_intervention_subgroups, :sd_key_question, foreign_key: true, index: { name: "index_cois_on_sd_key_question" }
    add_column :comparison_outcome_intervention_subgroups, :narrative_results, :text
  end
end
