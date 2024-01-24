class AddAsLimitOneReason < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :as_limit_one_reason, :boolean, default: true, null: false
  end
end
