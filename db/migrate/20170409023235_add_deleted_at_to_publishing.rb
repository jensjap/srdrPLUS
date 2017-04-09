class AddDeletedAtToPublishing < ActiveRecord::Migration[5.0]
  def change
    add_column :publishings, :deleted_at, :datetime
    add_column :publishings, :active, :boolean
    add_index :publishings, :deleted_at
    add_index :publishings, :active
    add_index :publishings, [:publishable_type, :publishable_id, :requested_by_id],          name: 'index_publishings_on_type_id_requested_by_id', where: 'deleted_at IS NULL'
    add_index :publishings, [:publishable_type, :publishable_id, :requested_by_id, :active], name: 'index_publishings_on_type_id_requested_by_id_uniq', unique: true
  end
end
