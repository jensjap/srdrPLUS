class AddFsLimitOneReason < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :fs_limit_one_reason, :boolean, default: true, null: false
  end
end
