class CreateDependencies < ActiveRecord::Migration[5.0]
  def change
    create_table :dependencies do |t|
      t.references :dependable,      polymorphic: true, index: { name: 'index_dependencies_on_dtype_did' }
      t.references :prerequisitable, polymorphic: true, index: { name: 'index_dependencies_on_ptype_pid' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :dependencies, :deleted_at
    add_index :dependencies, :active
    add_index :dependencies, [:dependable_type, :dependable_id, :prerequisitable_type, :prerequisitable_id, :deleted_at], name: 'index_dependencies_on_dtype_did_ptype_pid_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :dependencies, [:dependable_type, :dependable_id, :prerequisitable_type, :prerequisitable_id, :active],     name: 'index_dependencies_on_dtype_did_ptype_pid_active_uniq',     unique: true
  end
end
