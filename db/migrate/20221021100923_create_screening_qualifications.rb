class CreateScreeningQualifications < ActiveRecord::Migration[7.0]
  def change
    create_table :screening_qualifications do |t|
      t.references :citations_project
      t.references :user
      t.string :qualification_type
      t.timestamps
    end
    add_index :screening_qualifications, %i[citations_project_id user_id qualification_type],
              unique: true,
              name: 'cp_u_qt'
  end
end
