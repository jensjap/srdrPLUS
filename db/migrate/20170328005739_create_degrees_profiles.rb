class CreateDegreesProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :degrees_profiles do |t|
      t.references :degree, foreign_key: true
      t.references :profile, foreign_key: true

      t.timestamps
    end
  end
end

