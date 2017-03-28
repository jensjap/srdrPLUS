class AddActiveToDegreeholderships < ActiveRecord::Migration[5.0]
  def change
    add_column :degreeholderships, :active, :boolean
    add_index :degreeholderships, [:degree_id, :profile_id, :active], unique: true
  end
end
