class CreatePendingInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :pending_invitations do |t|
      t.references :invitation, foreign_key: true, type: :bigint
      t.references :user, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
