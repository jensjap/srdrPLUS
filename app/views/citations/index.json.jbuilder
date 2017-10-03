json.total_count @citations.total_count
json.pagination do
  json.more !@citations.last_page?
end
json.results do
  json.array!(@citations) do |citation|
    json.id citation.id
    json.text citation.name
  end
end

