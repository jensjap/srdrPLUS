json.total_count @review_types.count
json.incomplete_results false
json.items do
  json.array!(@review_types) do |review_type|
    json.id review_type.id
    json.name sanitize(review_type.name)
  end
end

