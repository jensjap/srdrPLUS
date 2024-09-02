class AddImportTypeToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :import_type, :string, default: "unknown"
  end
end
