class AddOtherReferenceToCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :citations_projects, :other_reference, :text
  end
end
