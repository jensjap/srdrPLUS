class CreateMlModels < ActiveRecord::Migration[6.1]
  def change
    create_table :ml_models do |t|
      t.integer :project_id, null: false
      t.string :timestamp, null: false

      t.timestamps
    end
    add_foreign_key :ml_models, :projects
  end
end
