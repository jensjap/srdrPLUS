class AddExtractionAndEfpsReferenceToMessages < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :extraction, null: true, foreign_key: true, type: :int
    add_reference :messages, :extraction_forms_projects_section, null: true, foreign_key: true, type: :int
  end
end
