class RemoveAutoTrainFromProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :auto_train, :boolean
  end
end
