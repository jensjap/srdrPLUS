class AddUniquenessIndexToSdOutcome < ActiveRecord::Migration[5.2]
  def change
    add_index(:sd_outcomes, [:sd_outcomeable_type, :sd_outcomeable_id, :name], unique: true, name: 'index_sd_outcomes_on_type_id_name')
  end
end
