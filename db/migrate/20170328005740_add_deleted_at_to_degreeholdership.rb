class AddDeletedAtToDegreeholdership < ActiveRecord::Migration[5.0]
  def change
    add_column :degreeholderships, :deleted_at, :datetime
    add_index :degreeholderships, :deleted_at
    add_index :degreeholderships, [:degree_id, :profile_id], where: 'deleted_at IS NULL'
  end
end
