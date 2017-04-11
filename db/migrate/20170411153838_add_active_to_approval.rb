class AddActiveToApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :active, :boolean
    add_index :approvals, :active
    add_index :approvals, [:approvable_type, :approvable_id, :user_id],          name: 'index_approvals_on_type_id_user_id', unique: true, where: 'deleted_at IS NULL'
    add_index :approvals, [:approvable_type, :approvable_id, :user_id, :active], name: 'index_approvals_on_type_id_user_id_active_uniq', unique: true
  end
end
