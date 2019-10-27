class CreateSdGreyLiteratureSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_grey_literature_searches do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.text :name

      t.timestamps
    end
  end
end
