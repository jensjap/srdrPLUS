class CreateSdSearchStrategies < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_search_strategies do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.references :sd_search_database, foreign_key: true
      t.string :date_of_search
      t.text :search_limits
      t.text :search_terms

      t.timestamps
    end
  end
end
