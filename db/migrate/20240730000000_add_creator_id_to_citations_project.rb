class AddCreatorIdToCitationsProject < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :creator_id, :integer
    add_index :citations_projects, :creator_id
    add_foreign_key :citations_projects, :users, column: :creator_id
  end
end
