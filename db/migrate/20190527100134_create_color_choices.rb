class CreateColorChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :color_choices, id: :integer do |t|
      t.string :name
      t.string :hex_code
      t.string :rgb_code

      t.timestamps
    end
  end
end
