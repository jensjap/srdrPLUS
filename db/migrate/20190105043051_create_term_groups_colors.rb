class CreateTermGroupsColors < ActiveRecord::Migration[5.0]
  def change
    create_table :term_groups_colors do |t|
      t.references :term_group, foreign_key: true
      t.references :color, foreign_key: true
    end
  end
end
