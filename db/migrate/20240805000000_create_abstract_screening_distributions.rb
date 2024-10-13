class CreateAbstractScreeningDistributions < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_distributions do |t|
      t.bigint :abstract_screening_id, null: false
      t.integer :user_id, null: false
      t.integer :citations_project_id, null: false
      t.timestamps
    end

    add_foreign_key :abstract_screening_distributions, :abstract_screenings
    add_foreign_key :abstract_screening_distributions, :users
    add_foreign_key :abstract_screening_distributions, :citations_projects
  end
end
