class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.text :attribution
      t.text :methodology_description
      t.string :prospero
      t.string :doi
      t.text :notes
      t.string :funding_source

      t.timestamps
    end

    add_index :projects, [:name, :description], length: { name: 10, description: 100 }, unique: true
  end
end
