class CreateDispatches < ActiveRecord::Migration[5.0]
  def change
    create_table :dispatches do |t|
      t.references :dispatchable, polymorphic: true, index: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :dispatches, :deleted_at
    add_index :dispatches, :active
    #add_index :dispatches, [:dispatchable_type, :dispatchable_id, :user_id],          name: 'index_dispatches_on_type_id_user_id',        unique: true, where: 'deleted_at IS NULL'
    #add_index :dispatches, [:dispatchable_type, :dispatchable_id, :user_id, :active], name: 'index_dispatches_on_type_id_user_id_active', unique: true
  end
end
