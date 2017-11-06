class CreateStudies < ActiveRecord::Migration[5.0]
  def change
    create_table :studies do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
