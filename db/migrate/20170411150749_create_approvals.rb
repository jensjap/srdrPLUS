class CreateApprovals < ActiveRecord::Migration[5.0]
  def change
    create_table :approvals do |t|
      t.references :approvable, polymorphic: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
