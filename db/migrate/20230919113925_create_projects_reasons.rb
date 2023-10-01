class CreateProjectsReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :projects_reasons do |t|
      t.references :project, null: false, type: :bigint
      t.references :reason, null: false, type: :bigint
      t.string :screening_type, null: false
      t.integer :pos, :integer, default: 999_999
      t.timestamps
    end

    add_index :projects_reasons, :pos
    add_index :projects_reasons, %i[project_id reason_id screening_type], unique: true, name: 'p_r_st_on_pr'
  end
end
