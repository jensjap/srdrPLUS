class AddAsLimitOneReason < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :as_limit_one_reason, :boolean, default: false, null: false
  end
end
