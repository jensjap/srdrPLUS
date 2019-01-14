class CreateTermGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :term_groups do |t|
      t.string :name
    end
  end
end
