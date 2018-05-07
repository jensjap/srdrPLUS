class CreateWacsBacsRssms < ActiveRecord::Migration[5.0]
  def change
    create_table :wacs_bacs_rssms do |t|
      t.references :wac
      t.references :bac
      t.references :result_statistic_sections_measure, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :wacs_bacs_rssms, :deleted_at
    add_index :wacs_bacs_rssms, :active
  end
end
