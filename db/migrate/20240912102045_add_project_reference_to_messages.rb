class AddProjectReferenceToMessages < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :project, null: true, foreign_key: true, type: :int
  end
end
