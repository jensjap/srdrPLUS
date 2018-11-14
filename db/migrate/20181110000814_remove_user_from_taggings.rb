class RemoveUserFromTaggings < ActiveRecord::Migration[5.0]
  def change
    remove_reference :taggings, :user, foreign_key: true
  end
end
