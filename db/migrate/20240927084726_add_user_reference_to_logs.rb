class AddUserReferenceToLogs < ActiveRecord::Migration[7.0]
  def change
    add_reference :logs, :user, null: true, type: :int, index: true
  end
end
