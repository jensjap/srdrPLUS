class CreateJournals < ActiveRecord::Migration[5.0]
  def change
    create_table :journals do |t|
      t.references :citation, foreign_key: true
      t.date :year
      t.integer :volume
      t.integer :issue
      t.string :name

      t.timestamps
    end
  end
end
