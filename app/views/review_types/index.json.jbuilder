json.total_count @review_types.count
json.incomplete_results false
json.items do
  json.array!(@review_types) do |review_type|
    json.extract! review_type, :id, :name
  end
end

