class AddForceTrainingToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :force_training, :boolean, default: false, null: false
  end
end
