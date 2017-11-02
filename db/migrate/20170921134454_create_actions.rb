class CreateActions < ActiveRecord::Migration[5.0]
  def change
    create_table :actions do |t|
      t.references :user, foreign_key: true
      t.references :action_type, foreign_key: true
      t.references :actionable, polymorphic: true
      t.integer :action_count

      t.timestamps
    end
  end
end
