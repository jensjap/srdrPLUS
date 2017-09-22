class CreateTaggings < ActiveRecord::Migration[5.0]
  def change
    create_table :taggings do |t|
      t.references :user, foreign_key: true
      t.references :tag, foreign_key: true
      t.references :taggable, polymorphic: true

      t.timestamps
    end
  end
end
