class UpdateComparisonsAssistedToExtractionsExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[7.0]
  def change
    say_with_time "Updating eefpst1s..." do
      ExtractionsExtractionFormsProjectsSectionsType1.all.update_all(comparisons_assisted: true)
    end
  end
end
