class CreateComparates < ActiveRecord::Migration[5.0]
  def change
    create_table :comparates do |t|
      t.references :comparable, polymorphic: true

      t.timestamps
    end
  end
end
