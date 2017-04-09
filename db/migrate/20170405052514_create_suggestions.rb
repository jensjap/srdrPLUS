class CreateSuggestions < ActiveRecord::Migration[5.0]
  def change
    create_table :suggestions do |t|
      t.references :suggestable, polymorphic: true, index: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
