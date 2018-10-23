class MakeCitationTitleLonger < ActiveRecord::Migration[5.0]
  def change
    change_column :citations, :name, :string, limit: 500
  end
end
