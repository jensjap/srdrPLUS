class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :room, null: false
      t.references :user, null: false
      t.boolean :admin, null: false, default: false

      t.timestamps
    end

    add_index :memberships, %i[user_id room_id], unique: true
  end
end
