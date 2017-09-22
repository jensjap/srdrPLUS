class CreatePredictions < ActiveRecord::Migration[5.0]
  def change
    create_table :predictions do |t|
      t.references :citations_project, foreign_key: true
      t.integer :value
      t.integer :num_yes_votes
      t.float :predicted_probability

      t.timestamps
    end
  end
end
