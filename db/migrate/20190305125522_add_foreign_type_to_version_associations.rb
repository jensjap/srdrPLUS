class AddForeignTypeToVersionAssociations < ActiveRecord::Migration[5.0]
  def change
    add_column :version_associations, :foreign_type, :string
    remove_index :version_associations,
      name: "index_version_associations_on_foreign_key"
    add_index :version_associations,
      %i(foreign_key_name foreign_key_id foreign_type),
      name: "index_version_associations_on_foreign_key"
  end
end
