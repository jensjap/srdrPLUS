class ChangeToUtf8mb4BinRest < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE citations ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE authors ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE journals ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE organizations ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE terms ROW_FORMAT=DYNAMIC CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
