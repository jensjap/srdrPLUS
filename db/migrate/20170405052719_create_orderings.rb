class CreateOrderings < ActiveRecord::Migration[5.0]
  def change
    create_table :orderings do |t|
      t.references :orderable, polymorphic: true
      t.integer :position
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :orderings, :deleted_at
    add_index :orderings, :active
    add_index :orderings, [:orderable_type, :orderable_id, :deleted_at], name: 'index_orderings_on_type_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :orderings, [:orderable_type, :orderable_id, :active],     name: 'index_orderings_on_type_id_active_uniq',     unique: true
  end
end
