class CreateComparisonOutcomePopulationSubgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :comparison_outcome_population_subgroups do |t|
      t.text :name
      t.text :narrative_results
      t.references :sd_meta_datum, foreign_key: true, type: :integer, index: { name: "index_cops_on_sd_meta_datum" }
      t.references :sd_key_question, foreign_key: true, type: :integer, index: { name: "index_cops_on_sd_key_question" }

      t.timestamps
    end
  end
end
