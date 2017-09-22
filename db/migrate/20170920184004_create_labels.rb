class CreateLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :labels do |t|
      t.references :citations_project, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :value

      t.timestamps
    end
  end
end
