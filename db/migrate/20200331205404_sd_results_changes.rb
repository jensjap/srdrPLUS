class SdResultsChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_outcomes do |t|
      t.string :name

      t.bigint  :sd_outcomeable_id
      t.string  :sd_outcomeable_type
      t.datetime :deleted_at
    end
    add_index :sd_outcomes, [:sd_outcomeable_id, :sd_outcomeable_type]
    add_index :sd_outcomes, [:name]

    drop_table :comparison_outcome_intervention_subgroups
    rename_table :comparison_outcome_population_subgroups, :sd_narrative_results
    change_table :sd_narrative_results do |t|
      t.remove :name
      t.text :narrative_results_by_population
      t.text :narrative_results_by_intervention
    end

    change_table :sd_evidence_tables do |t|
      t.references :sd_key_question
      t.string :outcome_name
    end

    rename_table :pairwise_meta_analytic_results , :sd_pairwise_meta_analytic_results 
    change_table :sd_pairwise_meta_analytic_results do |t|
      t.references :sd_key_question
      t.string :outcome_name
    end
    
    change_table :sd_meta_regression_analysis_results do |t|
      t.references :sd_key_question
      t.string :outcome_name
    end
  end
end
