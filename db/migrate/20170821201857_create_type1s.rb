class CreateType1s < ActiveRecord::Migration[5.0]
  def change
    create_table :type1s do |t|
      t.references :extraction_forms_projects_section, foreign_key: true
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :type1s, [:name, :description], unique: true
    add_index :type1s, :deleted_at
    add_index :type1s, [:extraction_forms_projects_section_id, :deleted_at], name: 'index_t1_on_efps_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
