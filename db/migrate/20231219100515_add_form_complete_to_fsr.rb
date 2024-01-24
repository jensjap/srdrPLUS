class AddFormCompleteToFsr < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screening_results, :form_complete, :boolean, default: false, null: false
  end
end
