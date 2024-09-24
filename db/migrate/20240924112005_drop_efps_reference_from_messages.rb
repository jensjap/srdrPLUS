class DropEfpsReferenceFromMessages < ActiveRecord::Migration[7.0]
  def change
    remove_reference :messages, :extraction_forms_projects_section
  end
end
