class CreateAbstrackrSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :abstrackr_settings do |t|
      t.references :profile, foreign_key: true, index: true
      t.column :authors_visible, :boolean, default: true
      t.column :journal_visible, :boolean, default: true
      t.timestamps
    end
  end
end
