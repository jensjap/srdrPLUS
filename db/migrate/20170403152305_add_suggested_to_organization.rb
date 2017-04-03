class AddSuggestedToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :suggested, :boolean, default: true
    add_index :organizations, :suggested
  end
end
