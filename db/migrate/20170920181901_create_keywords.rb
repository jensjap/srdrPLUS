class CreateKeywords < ActiveRecord::Migration[5.0]
  def change
    create_table :keywords do |t|
      t.references :citation, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
