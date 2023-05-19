class CreateMlModelsProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :ml_models_projects do |t|
      t.bigint :ml_model_id, null: false, foreign_key: true
      t.integer :project_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
