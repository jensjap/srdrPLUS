class CreateProjectsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :projects_tags do |t|
      t.references :project, null: false, type: :bigint
      t.references :tag, null: false, type: :bigint
      t.string :screening_type, null: false
      t.integer :pos, :integer, default: 999_999
      t.timestamps
    end

    add_index :projects_tags, :pos
    add_index :projects_tags, %i[project_id tag_id screening_type], unique: true
  end
end
