class AddUniqIndexToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_index :organizations, :name, unique: true
  end
end
