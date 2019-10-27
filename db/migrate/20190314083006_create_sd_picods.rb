class CreateSdPicods < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_picods do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.text :name
      t.string :p_type

      t.timestamps
    end
  end
end
