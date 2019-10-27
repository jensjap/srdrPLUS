class CreateSdMetaData < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_meta_data do |t|
      t.integer :project_id
      t.string :report_title
      t.datetime :date_of_last_search
      t.datetime :date_of_publication_to_srdr
      t.datetime :date_of_publication_full_report
      t.text :stakeholder_involvement_extent
      t.text :authors_conflict_of_interest_of_full_report
      t.text :stakeholders_conflict_of_interest
      t.text :prototcol_link
      t.text :full_report_link
      t.text :structured_abstract_link
      t.text :key_messages_link
      t.text :abstract_summary_link
      t.text :evidence_summary_link
      t.text :evs_introduction_link
      t.text :evs_methods_link
      t.text :evs_results_link
      t.text :evs_discussion_link
      t.text :evs_conclusions_link
      t.text :evs_tables_figures_link
      t.text :disposition_of_comments_link
      t.text :srdr_data_link
      t.text :most_previous_version_srdr_link
      t.text :most_previous_version_full_report_link
      t.text :overall_purpose_of_review
      t.string :type_of_review
      t.string :level_of_analysis
      t.string :state, null: false, default: 'DRAFT'

      t.timestamps
    end
  end
end
