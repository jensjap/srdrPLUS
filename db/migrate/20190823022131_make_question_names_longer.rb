class MakeQuestionNamesLonger < ActiveRecord::Migration[5.2]
  def up
    change_column :questions, :name, :text
  end
  def down
    change_column :questions, :name, :text
  end
end
