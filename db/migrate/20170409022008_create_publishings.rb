class CreatePublishings < ActiveRecord::Migration[5.0]
  def change
    create_table :publishings do |t|
      t.references :publishable, polymorphic: true, index: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :publishings, :deleted_at
    add_index :publishings, :active
    add_index :publishings, [:publishable_type, :publishable_id, :user_id, :deleted_at], name: 'index_publishings_on_type_id_user_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :publishings, [:publishable_type, :publishable_id, :user_id, :active],     name: 'index_publishings_on_type_id_user_id_active_uniq',     unique: true
  end
end
