class AddAutoTrainToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :auto_train, :boolean, default: false
  end
end
