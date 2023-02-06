@preview_type1_change_propagation.each do |k, v|
  json.set! k do
    json.array! v do |eefpst1|
      json.name eefpst1.citation.name
      json.username eefpst1.extraction.username
      json.name_and_description eefpst1.type1.name_and_description
    end
  end
end
json.loading false
json.all_type1s do
  json.array! ExtractionsExtractionFormsProjectsSectionsType1
    .extraction_collection(@efps.section.name, @efps.extraction_forms_project.id)
    .includes(:type1)
    .map(&:type1)
    .uniq { |type1| type1.id }.sort_by { |type1| type1.name }
end
