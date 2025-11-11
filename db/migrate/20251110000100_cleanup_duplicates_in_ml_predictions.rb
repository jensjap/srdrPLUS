# frozen_string_literal: true
class CleanupDuplicatesInMlPredictions < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL
      DELETE p
      FROM ml_predictions p
      JOIN (
        SELECT citations_project_id, ml_model_id, MIN(id) AS keep_id, COUNT(*) AS cnt
        FROM ml_predictions
        GROUP BY citations_project_id, ml_model_id
        HAVING COUNT(*) > 1
      ) d
      ON  p.citations_project_id = d.citations_project_id
      AND p.ml_model_id          = d.ml_model_id
      AND p.id                   <> d.keep_id;
    SQL
  end

  def down
    say "No-op: cannot restore deleted duplicates", true
  end
end
