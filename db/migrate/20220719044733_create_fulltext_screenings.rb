class CreateFulltextScreenings < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings do |t|
      t.references :project
      t.string :fulltext_screening_type, null: false, default: FulltextScreening::SINGLE_PERPETUAL
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
      t.boolean :exclusive_participants, null: false, default: false
      t.boolean :default, null: false, default: false
      t.timestamps
    end
  end
end
