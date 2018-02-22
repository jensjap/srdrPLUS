class CreateComparableElements < ActiveRecord::Migration[5.0]
  def change
    create_table :comparable_elements do |t|

      t.timestamps
    end
  end
end
