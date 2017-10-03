class ChangeDataTypeForPmidAndRefman < ActiveRecord::Migration[5.0]
  def change
    change_table :citations do |t|
      t.change :pmid, :string
      t.change :refman, :string
    end
  end
end
