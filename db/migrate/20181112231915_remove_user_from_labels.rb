class RemoveUserFromLabels < ActiveRecord::Migration[5.0]
  def change
    remove_reference :labels, :user, foreign_key: true
  end
end
