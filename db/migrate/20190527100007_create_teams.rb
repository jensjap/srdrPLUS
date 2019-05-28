class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams, id: :integer do |t|
      t.references :team_type, foreign_key: true, type: :integer
      t.references :project, foreign_key: true, type: :integer
      t.boolean :enabled
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :teams, :deleted_at
  end
end
