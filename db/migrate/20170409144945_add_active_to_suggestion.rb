class AddActiveToSuggestion < ActiveRecord::Migration[5.0]
  def change
    add_column :suggestions, :active, :boolean
    add_index :suggestions, :active
    add_index :suggestions, [:suggestable_type, :suggestable_id, :user_id], name: 'index_suggestions_on_type_id_user_id', unique: true, where: 'deleted_at IS NULL'
    add_index :suggestions, [:suggestable_type, :suggestable_id, :user_id, :active], name: 'index_suggestions_on_type_id_user_id_active_uniq', unique: true
  end
end
