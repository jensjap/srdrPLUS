class CreateAbstractScreeningsCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings_citations_projects do |t|
      t.references :abstract_screening, null: false, type: :bigint, index: { name: 'ascp_on_as' }
      t.references :citations_project, null: false, type: :bigint, index: { name: 'ascp_on_cp' }
      t.timestamps
    end
    add_index :abstract_screenings_citations_projects, %i[citations_project_id abstract_screening_id], unique: true,
                                                                                                       name: 'cp_id_on_as_id'
  end
end
