class AddActiveToDispatch < ActiveRecord::Migration[5.0]
  def change
    add_column :dispatches, :active, :boolean
    add_index :dispatches, :active
    add_index :dispatches, [:dispatchable_type, :dispatchable_id, :user_id],          name: 'index_dispatches_on_type_id_user_id', unique: true, where: 'deleted_at IS NULL'
    add_index :dispatches, [:dispatchable_type, :dispatchable_id, :user_id, :active], name: 'index_dispatches_on_type_id_user_id_active_uniq', unique: true
  end
end
