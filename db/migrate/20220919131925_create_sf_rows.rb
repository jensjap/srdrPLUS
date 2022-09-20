class CreateSfRows < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_rows do |t|
      t.string :name
      t.references :sf_question
      t.integer :position
      t.timestamps
    end
  end
end
