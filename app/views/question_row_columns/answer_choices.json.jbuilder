json.total_count @answer_choices.count
json.incomplete_results false
json.items do
  json.array!(@answer_choices) do |answer_choice|
    json.extract! answer_choice, :id, :name
    if answer_choice.suggestion
      json.suggestion do
        json.extract! answer_choice.suggestion.user.profile, :id
        json.set! :first_name, answer_choice.suggestion.user.handle
      end
    end
  end
end
