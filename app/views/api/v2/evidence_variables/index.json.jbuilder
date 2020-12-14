json.is_paginated @is_paginated.present?
json.page @page
json.per_page @per_page
json.evidenceVariable @evidence_variables do |ev|
  json.id ev.id
  json.url api_v2_evidence_variable_url(ev.id, format: :json)
  json.name "#{ ev.type1.name }"
end
