class CreateCitationsTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :citations_tasks do |t|
      t.references :citation, foreign_key: true
      t.references :task, foreign_key: true

      t.timestamps
    end
  end
end
