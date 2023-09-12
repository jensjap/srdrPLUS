class CreateTrainingDataInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :training_data_infos do |t|
      t.string :category
      t.integer :count
      t.references :ml_model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
