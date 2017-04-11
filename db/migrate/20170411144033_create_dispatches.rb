class CreateDispatches < ActiveRecord::Migration[5.0]
  def change
    create_table :dispatches do |t|
      t.references :dispatchable, polymorphic: true, index: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
