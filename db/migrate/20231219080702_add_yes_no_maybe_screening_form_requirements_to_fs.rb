class AddYesNoMaybeScreeningFormRequirementsToFs < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screenings, :yes_form_required, :boolean, default: false, null: false
    add_column :fulltext_screenings, :no_form_required, :boolean, default: false, null: false
    add_column :fulltext_screenings, :maybe_form_required, :boolean, default: false, null: false
  end
end
