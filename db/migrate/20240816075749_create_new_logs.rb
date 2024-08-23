class CreateNewLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.references :loggable, polymorphic: true, null: false
      t.string :description
      t.timestamps
    end
  end
end
