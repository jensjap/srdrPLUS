json.total_count @citations.count
json.incomplete_results false
json.items do
  json.array!(@citations) do |citation|
    json.extract! citation, :id, :name
  end
end

