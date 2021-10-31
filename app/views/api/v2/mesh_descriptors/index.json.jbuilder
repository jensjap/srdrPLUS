json.results @mesh_descriptors do |md|
  json.id       md[:id]
  json.text     md[:text]
  json.resource md[:resource_uri]
end
