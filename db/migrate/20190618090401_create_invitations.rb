class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.references :role, foreign_key: true, type: :integer
      t.references :invitable, polymorphic: true
      t.boolean :enabled, default: false
      t.string :token

      t.timestamps
    end

    add_index :invitations, :token, unique: true
  end
end
