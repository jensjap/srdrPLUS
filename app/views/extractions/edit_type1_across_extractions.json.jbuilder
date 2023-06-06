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
json.loading false
eefpst1s =
  ExtractionsExtractionFormsProjectsSectionsType1
  .unscope(:order)
  .extraction_collection(@efps.section.name, @efps.extraction_forms_project.id)
  .includes(:type1)
  .joins(:type1)
  .order('type1s.name ASC')
eefpst1s = eefpst1s.uniq { |eefpst1| [eefpst1.type1.name, eefpst1.type1.description] }

json.all_type1s do
  json.array! eefpst1s do |eefpst1|
    json.id eefpst1.type1.id
    json.name eefpst1.type1.name
    json.description eefpst1.type1.description
    json.type1_type eefpst1.type1_type
  end
end
