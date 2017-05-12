class CreateApprovals < ActiveRecord::Migration[5.0]
  def change
    create_table :approvals do |t|
      t.references :approvable, polymorphic: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :approvals, :deleted_at
    add_index :approvals, :active
    add_index :approvals, [:approvable_type, :approvable_id, :user_id, :deleted_at], name: 'index_approvals_on_type_id_user_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :approvals, [:approvable_type, :approvable_id, :user_id, :active],     name: 'index_approvals_on_type_id_user_id_active_uniq',     unique: true
  end
end
