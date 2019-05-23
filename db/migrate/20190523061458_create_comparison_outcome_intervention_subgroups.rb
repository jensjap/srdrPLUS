class CreateComparisonOutcomeInterventionSubgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :comparison_outcome_intervention_subgroups do |t|
      t.text :name
      t.references :sd_meta_datum, foreign_key: true, type: :integer, index: { name: "index_cois_on_sd_meta_datum_id" }

      t.timestamps
    end
  end
end
