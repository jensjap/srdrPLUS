class AddAbstractScreeningToCitationsProject < ActiveRecord::Migration[7.0]
  def change
    add_reference :citations_projects, :abstract_screening, foreign_key: true
  end
end
