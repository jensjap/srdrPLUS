json.evidenceVariable @evidence_variables do |ev|
  json.set! :id, ev.id
  json.set! :url, "http://srdrplus.ahrq.gov/api/v1/evidence_variables/#{ ev.id }.json"
  json.set! :name, "#{ ev.type1.name }"
  json.set! :title, "#{ ev.type1.name }"
end
