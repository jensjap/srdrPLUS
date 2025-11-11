# frozen_string_literal: true
class AddUniqueIndexToMlPredictions < ActiveRecord::Migration[7.0]
  def up
    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    if adapter.include?("mysql")
      execute <<~SQL
        ALTER TABLE ml_predictions
        ALGORITHM=INPLACE,
        LOCK=NONE,
        ADD UNIQUE INDEX index_ml_predictions_on_citations_project_id_and_ml_model_id
          (citations_project_id, ml_model_id);
      SQL
    else
      add_index :ml_predictions,
                [:citations_project_id, :ml_model_id],
                unique: true,
                name: :index_ml_predictions_on_citations_project_id_and_ml_model_id
    end
  end

  def down
    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    if adapter.include?("mysql")
      execute <<~SQL
        ALTER TABLE ml_predictions
        DROP INDEX index_ml_predictions_on_citations_project_id_and_ml_model_id;
      SQL
    else
      remove_index :ml_predictions, name: :index_ml_predictions_on_citations_project_id_and_ml_model_id
    end
  end
end
