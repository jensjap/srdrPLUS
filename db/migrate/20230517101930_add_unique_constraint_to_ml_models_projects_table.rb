class AddUniqueConstraintToMlModelsProjectsTable < ActiveRecord::Migration[7.0]
  def change
    add_index :ml_models_projects, [:ml_model_id, :project_id], unique: true
  end
end
