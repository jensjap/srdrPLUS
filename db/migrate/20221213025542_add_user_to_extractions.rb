class AddUserToExtractions < ActiveRecord::Migration[7.0]
  def change
    add_reference :extractions, :user, null: true, foreign_key: true, type: :int
  end
end
