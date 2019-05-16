class ChangeToUtf8mb4Bin < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE key_questions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
