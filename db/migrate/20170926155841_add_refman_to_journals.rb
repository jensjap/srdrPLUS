class AddRefmanToJournals < ActiveRecord::Migration[5.0]
  def change
    add_column :journals, :refman, :integer
  end
end
