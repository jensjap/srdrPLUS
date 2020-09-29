class AddHiddenToEfps < ActiveRecord::Migration[5.2]
  def change
    add_column :extraction_forms_projects_sections, :hidden, :boolean, default: false
  end
end
