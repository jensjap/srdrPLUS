class MakeRecordNameText < ActiveRecord::Migration[5.2]
  def up
    change_column :records, :name, :text
  end
  def down
    change_column :records, :name, :string
  end
end
