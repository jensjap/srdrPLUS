class DropProjectColumnFromMlModelsTable < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :ml_models, :projects, if_exists: true
    remove_column :ml_models, :project_id, :integer, null: false
  end
end
