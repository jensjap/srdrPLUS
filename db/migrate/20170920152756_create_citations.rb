class CreateCitations < ActiveRecord::Migration[5.0]
  def change
    create_table :citations do |t|
      t.references :citation_type, foreign_key: true
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :citations, :deleted_at
  end
end
