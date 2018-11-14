class RemoveUserFromNotes < ActiveRecord::Migration[5.0]
  def change
    remove_reference :notes, :user, foreign_key: true
  end
end
