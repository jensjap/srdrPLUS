class CreateAbstractScreenings < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screenings do |t|
      t.references :project
      t.string :abstract_screening_type, null: false, default: AbstractScreening::SINGLE_PERPETUAL
      t.integer :no_of_citations, null: false, default: 0
      t.boolean :exclusive_users, null: false, default: false
      t.boolean :yes_tag_required, null: false, default: false
      t.boolean :no_tag_required, null: false, default: false
      t.boolean :maybe_tag_required, null: false, default: false
      t.boolean :yes_reason_required, null: false, default: false
      t.boolean :no_reason_required, null: false, default: false
      t.boolean :maybe_reason_required, null: false, default: false
      t.boolean :yes_note_required, null: false, default: false
      t.boolean :no_note_required, null: false, default: false
      t.boolean :maybe_note_required, null: false, default: false
      t.boolean :only_predefined_reasons, null: false, default: false
      t.boolean :only_predefined_tags, null: false, default: false
      t.boolean :hide_author, null: false, default: false
      t.boolean :hide_journal, null: false, default: false
      t.boolean :default, null: false, default: false
      t.timestamps
    end
  end
end
