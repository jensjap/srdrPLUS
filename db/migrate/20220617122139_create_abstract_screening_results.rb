class CreateAbstractScreeningResults < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_results do |t|
      t.references :projects_users_role
      t.references :abstract_screening
      t.references :citations_project
      t.timestamps
    end
  end
end
