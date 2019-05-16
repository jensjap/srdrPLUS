class ChangeToUtf8mb4BinRest < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE citations CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE authors CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE journals CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE organizations CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE terms CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
