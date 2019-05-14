json.total_count @key_questions.count
json.incomplete_results false
json.items do
  json.array!(@key_questions) do |key_question|
    json.extract! key_question, :id, :name
  end
end
