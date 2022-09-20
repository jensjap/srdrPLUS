class CreateSfColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_columns do |t|
      t.string :name
      t.references :sf_question
      t.integer :position
      t.timestamps
    end
  end
end
