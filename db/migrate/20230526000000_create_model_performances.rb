class CreateModelPerformances < ActiveRecord::Migration[6.0]
  def change
    create_table :model_performances do |t|
      t.references :ml_model, foreign_key: true
      t.string :label
      t.float :score

      t.timestamps
    end
  end
end