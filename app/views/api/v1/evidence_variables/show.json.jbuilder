json.set! :resourceType, "EvidenceVariable"
json.set! :id, @evidence_variable.id.to_s
json.set! :meta do
  json.set! :versionId, '1'
end
json.set! :url_index, "http://srdrPLUS.ahrq.gov/api/v1/evidence_variables"
json.set! :url, "http://srdrPLUS.ahrq.gov/api/v1/evidence_variables/#{ @evidence_variable.id }.json"
json.set! :name, "#{ @evidence_variable.type1.name } at #{ @timepoint_name } #{ @timepoint_unit }"
json.set! :title, "#{ @evidence_variable.type1.name } at #{ @timepoint_name } #{ @timepoint_unit }"
json.set! :status, "active"
json.set! :date, @evidence_variable.created_at
json.set! :description, "#{ @evidence_variable.type1.name } at #{ @timepoint_name } #{ @timepoint_unit }"
#json.set! :characteristicCombination, "union"
json.set! :characteristic, Jbuilder.new.array!(['']) do
  json.set! :description, "#{ @evidence_variable.type1.name }"
  json.set! :definitionCodeableConcept do
    json.set! :coding, Jbuilder.new.array!(['']) do
      json.set! :system, "http://snomed.info/sct"
      json.set! :code, "419099009"
      json.set! :display, "xxxxx"
    end
  end
  json.set! :exclude, false
  json.set! :timeFromStart do
    json.set! :quantity do
      if @timepoint_name.eql? "Baseline"
        json.set! :value, "0"
        json.set! :comparator, "="
      else
        json.set! :value, @timepoint_name
        json.set! :comparator, "="
        json.set! :unit, @timepoint_unit
        json.set! :system, "http://unitsofmeasure.org"
        json.set! :code, "u"
      end
    end
  end
end
