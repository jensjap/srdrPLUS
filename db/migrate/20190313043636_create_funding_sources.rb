class CreateFundingSources < ActiveRecord::Migration[5.0]
  def change
    create_table :funding_sources do |t|
      t.text :name

      t.timestamps
    end
  end
end
