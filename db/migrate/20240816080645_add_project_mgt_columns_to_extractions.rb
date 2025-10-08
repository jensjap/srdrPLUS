class AddProjectMgtColumnsToExtractions < ActiveRecord::Migration[7.0]
  def change
    add_reference :extractions, :assignor, null: true, type: :int, index: true, foreign_key: { to_table: :users }
    add_column :extractions, :status, :string
  end
end
