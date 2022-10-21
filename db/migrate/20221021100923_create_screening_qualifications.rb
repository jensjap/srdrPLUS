class CreateScreeningQualifications < ActiveRecord::Migration[7.0]
  def change
    create_table :screening_qualifications do |t|
      t.references :citation
      t.references :project
      t.string :qualification_type
      t.timestamps
    end
    add_index :screening_qualifications, %i[citation_id project_id qualification_type],
              unique: true,
              name: 'c_p_qt'
  end
end
