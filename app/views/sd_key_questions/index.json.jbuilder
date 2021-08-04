json.total_count @sd_key_questions.count
json.incomplete_results false
json.items do
  json.array!(@sd_key_questions) do |sd_key_question|
    json.id sd_key_question.id
    json.name sanitize(sd_key_question.name)
  end
end
