class CreateSdProjectLeads < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_project_leads do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
