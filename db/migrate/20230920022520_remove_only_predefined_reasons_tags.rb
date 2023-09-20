class RemoveOnlyPredefinedReasonsTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :abstract_screenings, :only_predefined_reasons
    remove_column :abstract_screenings, :only_predefined_tags
    remove_column :fulltext_screenings, :only_predefined_reasons
    remove_column :fulltext_screenings, :only_predefined_tags
  end
end
