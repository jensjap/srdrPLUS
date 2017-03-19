class CreateUserDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :user_details do |t|
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.string :username
      t.references :title, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name

      t.timestamps
    end
  end
end
