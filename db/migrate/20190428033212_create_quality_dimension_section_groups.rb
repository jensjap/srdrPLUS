class CreateQualityDimensionSectionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :quality_dimension_section_groups do |t|
      t.column :name, :string
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    change_table :quality_dimension_sections do |t|
      t.references :quality_dimension_section_group, index: { name: :index_qds_on_qdsg_id }
    end
  end
end
