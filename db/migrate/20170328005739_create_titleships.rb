class CreateTitleships < ActiveRecord::Migration[5.0]
  def change
    create_table :titleships do |t|
      t.references :profile, foreign_key: true
      t.references :title, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :titleships, :deleted_at
    add_index :titleships, [:profile_id, :title_id], where: 'deleted_at IS NULL'
  end
end
