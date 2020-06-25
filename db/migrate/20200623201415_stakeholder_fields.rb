class StakeholderFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :sd_meta_data, :stakeholder_involvement_extent, :text
    remove_column :sd_meta_data, :stakeholders_conflict_of_interest, :text
    add_column :sd_meta_data, :stakeholders_key_informants, :text
    add_column :sd_meta_data, :stakeholders_technical_experts, :text
    add_column :sd_meta_data, :stakeholders_peer_reviewers, :text
    add_column :sd_meta_data, :stakeholders_others, :text
  end
end
