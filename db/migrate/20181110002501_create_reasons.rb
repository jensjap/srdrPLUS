class CreateReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :reasons do |t|
      t.string :name, limit: 1000

      t.timestamps
    end
  end
end
