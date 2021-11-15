class AddHelperMessageToEfps < ActiveRecord::Migration[5.2]
  def change
    add_column :extraction_forms_projects_sections, :helper_message, :string
  end
end
