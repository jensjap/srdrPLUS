class AddDefaultToType1TypeId < ActiveRecord::Migration[7.0]
  def change
    change_column_default :extractions_extraction_forms_projects_sections_type1s, :type1_type_id, 1
  end
end
