class CreateSdPicodsTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_picods_types do |t|
      t.string :name

      t.timestamps
    end

    remove_column :sd_picods, :p_type, :string
  end
end
