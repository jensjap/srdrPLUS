class ChangeVolumeIssueInJournals < ActiveRecord::Migration[5.2]
  def change
    change_column :journals, :volume, :string
    change_column :journals, :issue, :string
  end
end
