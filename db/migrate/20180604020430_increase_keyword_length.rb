class IncreaseKeywordLength < ActiveRecord::Migration[5.0]
  def change
    change_column :keywords, :name, :string, limit: 5000
  end
end
