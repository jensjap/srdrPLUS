class DropLogs < ActiveRecord::Migration[7.0]
  def change
    drop_table :logs
  end
end
