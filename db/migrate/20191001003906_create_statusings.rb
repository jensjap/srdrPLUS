class CreateStatusings < ActiveRecord::Migration[5.2]
  def change
    create_table :statusings do |t|
      t.references :statusable, polymorphic: true
      t.references :status, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active
      
      t.timestamps
    end

    add_index :statusings, :deleted_at
    add_index :statusings, :active
    add_index :statusings, [:statusable_type, :statusable_id, :status_id, :deleted_at], name: 'index_statusings_on_type_id_status_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :statusings, [:statusable_type, :statusable_id, :status_id, :active],     name: 'index_statusings_on_type_id_status_id_active_uniq',     unique: true
  end
end
