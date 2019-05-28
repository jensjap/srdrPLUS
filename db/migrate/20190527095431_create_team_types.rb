class CreateTeamTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :team_types, id: :integer do |t|
      t.string :name

      t.timestamps
    end
  end
end
