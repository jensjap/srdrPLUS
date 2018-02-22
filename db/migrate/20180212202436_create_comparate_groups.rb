class CreateComparateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :comparate_groups do |t|

      t.timestamps
    end
  end
end
