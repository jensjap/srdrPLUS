class AddRefmanToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :refman, :text
  end
end
