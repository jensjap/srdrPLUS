json.total_count @key_question_types.count
json.incomplete_results false
json.items do
  json.array!(@key_question_types) do |key_question_type|
    json.id key_question_type.id
    json.name CGI.escapeHTML(key_question_type.name)
  end
end
