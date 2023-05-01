class AddActiveToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :active, :boolean, default: true
  end
end
