class CreateSdOtherItems < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_other_items do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.text :name
      t.text :url

      t.timestamps
    end
  end
end
