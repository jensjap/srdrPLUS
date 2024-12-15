class AddMlScoreAndLabeledToAbstractScreeningDistributions < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screening_distributions, :ml_score, :float
    add_column :abstract_screening_distributions, :labeled, :boolean, default: false
  end
end
