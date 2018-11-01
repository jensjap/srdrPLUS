class CreateCitationsTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :citations_tasks do |t|
      t.references :citation, foreign_key: true
      t.references :task, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active
    end
    add_index :citations_tasks, :deleted_at
    add_index :citations_tasks, :active
  end
end
