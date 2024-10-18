class AddProjectIdToWordGroupsAndWordWeights < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:word_groups, :project_id)
      add_reference :word_groups, :project, foreign_key: true, type: :integer
    end

    unless column_exists?(:word_weights, :project_id)
      add_reference :word_weights, :project, foreign_key: true, type: :integer
    end

    WordGroup.reset_column_information
    WordWeight.reset_column_information

    WordGroup.find_each do |word_group|
      if word_group.project_id.nil?
        if word_group.abstract_screening_id
          project_id = AbstractScreening.where(id: word_group.abstract_screening_id).pluck(:project_id).first
          word_group.update_columns(project_id: project_id)
        else
          word_group.update_columns(project_id: nil)
        end
      end
    end

    WordWeight.find_each do |word_weight|
      if word_weight.project_id.nil?
        if word_weight.abstract_screening_id
          project_id = AbstractScreening.where(id: word_weight.abstract_screening_id).pluck(:project_id).first
          word_weight.update_columns(project_id: project_id)
        else
          word_weight.update_columns(project_id: nil)
        end
      end
    end

    WordWeight.joins(:word_group).where(word_groups: { project_id: nil }).delete_all
    WordGroup.where(project_id: nil).delete_all
    WordWeight.where(project_id: nil).delete_all

    change_column_null :word_groups, :project_id, false
    change_column_null :word_weights, :project_id, false
  end

  def down
    remove_reference :word_groups, :project
    remove_reference :word_weights, :project
  end
end
