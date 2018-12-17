class AddProjectToScreeningOptions < ActiveRecord::Migration[5.0]
  def change
    add_reference :screening_options, :project, foreign_key: true
  end
end
