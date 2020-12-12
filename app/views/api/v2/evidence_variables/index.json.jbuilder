json.evidenceVariable @evidence_variables do |ev|
  json.set! :id, ev.id
  json.url api_v2_evidence_variable_url(ev.id, format: :json)
  json.set! :name, "#{ ev.type1.name }"
end
