class CreateExtractionsType1s < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_type1s do |t|
      t.references :extraction, foreign_key: true, index: { name: 'index_et1_on_e_id' }
      t.references :type1, foreign_key: true,      index: { name: 'index_et1_on_t1_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extractions_type1s, :deleted_at, name: 'index_et1_on_deleted_at'
    add_index :extractions_type1s, :active,     name: 'index_et1_on_active'
    add_index :extractions_type1s, [:extraction_id, :type1_id, :deleted_at], name: 'index_et1_on_e_id_t1_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extractions_type1s, [:extraction_id, :type1_id, :active],     name: 'index_et1_on_e_id_t1_id_active'
  end
end
