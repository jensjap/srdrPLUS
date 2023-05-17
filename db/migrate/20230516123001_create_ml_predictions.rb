class CreateMlPredictions < ActiveRecord::Migration[6.1]
  def change
    create_table :ml_predictions do |t|
      t.integer :citations_project_id, null: false
      t.bigint :ml_model_id, null: false
      t.float :score, null: false

      t.timestamps
    end
    add_foreign_key :ml_predictions, :citations_projects
    add_foreign_key :ml_predictions, :ml_models
  end
end
