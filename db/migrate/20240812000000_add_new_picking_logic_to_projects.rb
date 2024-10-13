class AddNewPickingLogicToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :new_picking_logic, :boolean, default: true

    reversible do |dir|
      dir.up do
        Project.update_all(new_picking_logic: false)
      end
    end
  end
end
