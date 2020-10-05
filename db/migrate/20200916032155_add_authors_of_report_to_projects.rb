class AddAuthorsOfReportToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :authors_of_report, :text
  end
end
