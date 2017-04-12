class CreateDispatches < ActiveRecord::Migration[5.0]
  def change
    create_table :dispatches do |t|
      t.references :dispatchable, polymorphic: true, index: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :dispatches, [:dispatchable_type, :dispatchable_id, :user_id], name: 'index_dispatches_on_type_id_user_id', where: 'deleted_at IS NULL'
  end
end
