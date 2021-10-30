class CreateMeshDescriptors < ActiveRecord::Migration[5.2]
  def change
    create_table :mesh_descriptors do |t|
      t.text :name

      t.timestamps
    end
  end
end
