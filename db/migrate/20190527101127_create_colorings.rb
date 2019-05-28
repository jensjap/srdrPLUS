class CreateColorings < ActiveRecord::Migration[5.2]
  def change
    create_table :colorings, id: :integer do |t|
      t.references :colorable, polymorphic: true
      t.references :color_choice, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
