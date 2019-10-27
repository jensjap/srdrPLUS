class CreateSdPrismaFlows < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_prisma_flows do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.text :name

      t.timestamps
    end
  end
end
