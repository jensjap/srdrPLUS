class CreateJoinTableCitationsProjectsAbstractScreenings < ActiveRecord::Migration[7.0]
  def change
    create_join_table :citations_projects, :abstract_screenings do |t|
      t.index %i[citations_project_id abstract_screening_id], unique: true, name: 'cp_id_on_as_id'
      t.index :abstract_screening_id, name: 'cpas_id_on_as_id'
    end
  end
end
