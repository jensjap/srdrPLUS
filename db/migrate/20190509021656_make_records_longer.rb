class MakeRecordsLonger < ActiveRecord::Migration[5.2]
  def change
    change_column :records, :name, :text
  end
end
