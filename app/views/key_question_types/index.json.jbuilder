json.total_count @key_question_types.count
json.incomplete_results false
json.items do
  json.array!(@key_question_types) do |key_question_type|
    json.extract! key_question_type, :id, :name
  end
end
