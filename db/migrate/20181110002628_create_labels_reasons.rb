class CreateLabelsReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :labels_reasons do |t|
      t.references :label, foreign_key: true
      t.references :reason, foreign_key: true

      t.timestamps
    end
  end
end
