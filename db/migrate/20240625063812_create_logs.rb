class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.references :assignment
      t.string :description

      t.timestamps
    end
  end
end
