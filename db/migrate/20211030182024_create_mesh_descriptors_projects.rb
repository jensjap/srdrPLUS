class CreateMeshDescriptorsProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :mesh_descriptors_projects do |t|
      t.references :mesh_descriptor, null: false, type: :bigint
      t.references :project, null: false, type: :bigint

      t.timestamps
    end
  end
end
