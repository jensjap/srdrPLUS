class AddYesNoMaybeScreeningFormRequirementsToAs < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screenings, :yes_form_required, :boolean, default: false, null: false
    add_column :abstract_screenings, :no_form_required, :boolean, default: false, null: false
    add_column :abstract_screenings, :maybe_form_required, :boolean, default: false, null: false
  end
end
