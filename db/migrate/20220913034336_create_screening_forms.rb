class CreateScreeningForms < ActiveRecord::Migration[7.0]
  def change
    create_table :screening_forms do |t|
      t.references :project
      t.string :form_type, null: false
      t.timestamps
    end
  end
end
