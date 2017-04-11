class CreatePublishings < ActiveRecord::Migration[5.0]
  def change
    create_table :publishings do |t|
      t.references :publishable, polymorphic: true, index: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
